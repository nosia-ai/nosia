module Document::Chunkable
  extend ActiveSupport::Concern

  included do
    has_many :chunks, dependent: :destroy
  end

  def chunkify!
    splitter = ::Baran::CharacterTextSplitter.new(
      chunk_size: 1024,
      chunk_overlap: 64,
      separator: "\n\n"
    )

    new_chunks = splitter.chunks(self.content)

    self.chunks.destroy_all

    new_chunks.each do |new_chunk|
      chunk = self.chunks.create!(content: new_chunk.dig(:text))
      chunk.vectorize!
    end
  end
end
