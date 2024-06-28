class Chunk < ApplicationRecord
  include Vectorizable

  belongs_to :document
end
