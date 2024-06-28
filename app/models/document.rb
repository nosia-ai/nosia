class Document < ApplicationRecord
  include Chunkable, Parsable, Vectorizable

  has_one_attached :file

  validates :file, presence: true

  def titlize!
    update(title: file.filename.to_s)
  end
end
