class Text < ApplicationRecord
  include Chunkable

  belongs_to :account

  def context
    data
  end

  def resume
    data&.first(50)
  end

  def title
    data&.first(25)
  end
end
