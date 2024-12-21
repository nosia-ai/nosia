class Text < ApplicationRecord
  include Chunkable

  belongs_to :account

  def context
    body
  end
end
