class Chunk < ApplicationRecord
  include Vectorizable

  belongs_to :chunkable, polymorphic: true
end
