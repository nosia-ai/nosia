module Website::Crawlable
  extend ActiveSupport::Concern

  def crawl_urls!
    urls.each do |website_url|
      website = Website.where(account: self.account, url: website_url).first_or_create
      website.crawl_url! if website.new_record? || !website.data
    end
  end

  def crawl_url!
    return unless ENV["DOCLING_SERVE_BASE_URL"].present?

    connection = Faraday.new(url: ENV["DOCLING_SERVE_BASE_URL"])

    request_body = {
      http_source: {
        url: self.url,
      },
      options: {
        include_images: false,
        output_docling_document: false,
        output_markdown: true
      }
    }

    response = connection.post do |request|
      request.url "/convert"
      request.headers["Content-Type"] = "application/json"
      request.headers["Accept"] = "application/json"
      request.headers["User-Agent"] = "Nosiabot/0.1"
      request.body = request_body.to_json
    end

    return unless response.success?
    parsed_response = JSON.parse(response.body)
    self.data = parsed_response.dig("document", "markdown")
    self.save!
  end

  private

  def extract_sitemap_urls_from_robots_txt(robots_txt)
    sitemap_urls = robots_txt.split("\n").map do |line|
      line.strip.match(/\ASitemap:\s*(.+)$/i)&.captures&.first
    end.compact
  end

  def extract_urls_from_sitemap(xml)
    doc = Nokogiri::XML(xml)
    namespace = { sitemap: "http://www.sitemaps.org/schemas/sitemap/0.9" }
    doc.xpath("//sitemap:urlset/sitemap:url/sitemap:loc", namespace).map(&:text)
  end

  def fetch_robots_txt
    fetch_uri("/robots.txt")
  end

  def fetch_sitemap(uri)
    fetch_uri(uri)
  end

  def fetch_uri(uri)
    connection = Faraday.new(url:)
    response = connection.get(uri) do |request|
      request.headers["User-Agent"] = "Nosiabot/0.1"
    end
    if response.success?
      response.body
    else
      nil
    end
  end

  def urls
    robots_txt = fetch_robots_txt
    sitemap_urls = extract_sitemap_urls_from_robots_txt(robots_txt)
    return unless sitemap_urls.any?

    urls = []

    sitemap_urls.each do |sitemap_url|
      sitemap = fetch_sitemap(sitemap_url)
      urls << extract_urls_from_sitemap(sitemap)
    end

    urls.flatten.uniq
  end
end
