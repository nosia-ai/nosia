class Website < ApplicationRecord
  include Chunkable
  include Crawlable

  belongs_to :account
end
