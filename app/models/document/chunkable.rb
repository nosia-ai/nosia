module Document::Chunkable
  extend ActiveSupport::Concern

  included do
    has_many :chunks, as: :chunkable, dependent: :destroy
  end

  def chunkify!
    separators = JSON.parse(ENV.fetch("SEPARATORS", [ "\n\n", "\n", " " ].to_s))

    splitter = ::Baran::RecursiveCharacterTextSplitter.new(
      chunk_size: ENV.fetch("CHUNK_SIZE", 1000).to_i,
      chunk_overlap: ENV.fetch("CHUNK_OVERLAP", 200).to_i,
      separators:,
    )

    new_chunks = splitter.chunks(self.content)

    self.chunks.destroy_all

    new_chunks.each do |new_chunk|
      chunk = self.chunks.create!(account:, content: new_chunk.dig(:text))
      chunk.vectorize!
    end
  end
end
