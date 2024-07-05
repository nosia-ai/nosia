module Document::Parsable
  extend ActiveSupport::Concern

  def parse
    self.file.blob.open do |io|
      system("pdftotext", io.path, io.path + ".txt")
      self.content = File.read(io.path + ".txt")
    end
  end

  def parse!
    parse
    save!
  end
end
