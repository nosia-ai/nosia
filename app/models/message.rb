class Message < ApplicationRecord
  include ActionView::RecordIdentifier

  enum role: { system: 0, assistant: 10, user: 20 }

  belongs_to :chat

  after_create_commit -> { broadcast_created }
  after_update_commit -> { broadcast_updated }

  def broadcast_created
    broadcast_append_later_to(
      "#{dom_id(chat)}_messages",
      partial: "messages/message",
      locals: { message: self, scroll_to: true },
      target: "#{dom_id(chat)}_messages"
    )
  end

  def broadcast_updated
    broadcast_append_to(
      "#{dom_id(chat)}_messages",
      partial: "messages/message",
      locals: { message: self, scroll_to: true },
      target: "#{dom_id(chat)}_messages"
    )
  end

  def similar_documents
    Document.where(id: similar_document_ids)
  end

  def to_html
    Commonmarker.to_html(content)
  end
end
