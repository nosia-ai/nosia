module Document::Parsable
  extend ActiveSupport::Concern

  def parse
    self.file.blob.open do |io|
      reader = ::PDF::Reader.new(io)
      self.content = reader.pages.map(&:text).join("\n\n")
    end
  end

  def parse!
    parse
    save!
  end
end
