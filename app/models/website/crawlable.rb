module Website::Crawlable
  extend ActiveSupport::Concern

  def crawl!
    return unless ENV["DOCLING_SERVE_BASE_URL"].present?

    connection = Faraday.new(url: ENV["DOCLING_SERVE_BASE_URL"])

    request_body = {
      http_source: {
        url: self.url
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
      request.body = request_body.to_json
    end

    Rails.logger.info response
    return unless response.success?
    parsed_response = JSON.parse(response.body)
    self.data = parsed_response.dig("document", "markdown")
    self.save!
  end
end
