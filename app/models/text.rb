class Text < ApplicationRecord
  include Chunkable

  belongs_to :account
end
