class Document < ApplicationRecord
  include Parsable, Vectorizable

  has_one_attached :file
end
