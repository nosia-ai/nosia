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

    search_results = Chunk.similarity_search(chat.last_question, k: 4)
    message.update(similar_document_ids: search_results.pluck(:document_id).uniq)

    question = chat.last_question
    context = search_results.map(&:content).join("\n---\n")

    prompt = [
      ["Contexte :", context].join("\n"),
      ["Question :", question].join("\n"),
      ["Réponse :"]
    ].join("\n---\n")

    llm = LangchainrbRails.config.vectorsearch.llm
    llm.chat(messages: [{role: "user", content: prompt}]) do |stream|
      new_content = stream.raw_response.dig("message", "content")
      message.update(content: message.content + new_content) if new_content
    end
  end
end
