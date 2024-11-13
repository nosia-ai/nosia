class Author < ApplicationRecord
  has_many :documents, dependent: :nullify
end
