class CrawlWebsiteJob < ApplicationJob
  queue_as :default

  def perform(website_id)
    website = Website.find(website_id)
    website.crawl!
    website.chunkify! if website.data.present?
  end
end
