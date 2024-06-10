class AddDocumentJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    document.parse!
    document.vectorize! if document.content.present?
  end
end
