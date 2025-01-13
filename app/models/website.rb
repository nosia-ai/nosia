class Website < ApplicationRecord
  include Chunkable
  include Crawlable

  belongs_to :account

  def context
    data
  end

  def resume
    data&.first(50)
  end

  def title
    data&.first(50) || url
  end
end
