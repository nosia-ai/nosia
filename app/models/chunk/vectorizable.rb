module Chunk::Vectorizable
  extend ActiveSupport::Concern

  included do
    vectorsearch
  end

  def as_vector
    self.content
  end

  def vectorize!
    upsert_to_vectorsearch
  end
end
