module Document::Chunkable
  extend ActiveSupport::Concern

  included do
    has_many :chunks, dependent: :destroy
  end

  def chunkify!
    splitter = ::Baran::RecursiveCharacterTextSplitter.new(
      chunk_size: ENV.fetch("CHUNK_SIZE", 1000),
      chunk_overlap: ENV.fetch("CHUNK_SIZE", 200),
      separator: ENV.fetch("SEPARATORS", ["\n\n", "\n", " "])
    )

    new_chunks = splitter.chunks(self.content)

    self.chunks.destroy_all

    new_chunks.each do |new_chunk|
      chunk = self.chunks.create!(content: new_chunk.dig(:text))
      chunk.vectorize!
    end
  end
end
