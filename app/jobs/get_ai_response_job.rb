class GetAiResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id)
    chat = Chat.find(chat_id)
    call_ollama(chat:)
  end

  private

  def create_message(chat:)
    response_number = (chat.messages.where(role: "assistant").order(:created_at).last&.response_number || 0) + 1
    message = chat.messages.create(role: "assistant", content: "", response_number:)
    message.broadcast_created
    message
  end

  def call_ollama(chat:)
    message = create_message(chat:)
    Document.ask(chat.last_question, k: 4) do |stream|
      new_content = stream.raw_response.dig("message", "content")
      message.update(content: message.content + new_content) if new_content
    end
  end
end
