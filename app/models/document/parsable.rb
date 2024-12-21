module Document::Parsable
  extend ActiveSupport::Concern

  def parse
    content_type = self.file.blob.content_type

    if content_type.start_with?("text/")
      parse_text
    elsif ENV["DOCLING_SERVE_BASE_URL"].present?
      parse_with_docling
    elsif content_type.eql?("application/pdf")
      parse_pdf
    end
  end

  def parse!
    parse
    save!
  end

  def parse_pdf
    self.file.blob.open do |io|
      reader = ::PDF::Reader.new(io)
      self.content = reader.pages.map(&:text).join("\n\n")
    end
  end

  def parse_text
    self.file.blob.open do |io|
      self.content = io.read
    end
  end

  def parse_with_docling
    connection = Faraday.new(url: ENV["DOCLING_SERVE_BASE_URL"])

    base64_string = Base64.strict_encode64(self.file.download)

    request_body = {
      file_source: {
        base64_string:,
        filename: self.file.filename.to_s
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

    return unless response.success?
    parsed_response = JSON.parse(response.body)
    self.content = parsed_response.dig("document", "markdown")
    self.save!
  end
end
