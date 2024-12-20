class Qna < ApplicationRecord
  include Chunkable

  belongs_to :account
end
