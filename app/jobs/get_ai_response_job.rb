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
    context = search_results.map(&:content).join("\n\n")

    prompt = [
      ["Context:", context].join("\n"),
      ["---", "Now here is the question you need to answer.", "Question: #{question}"].join("\n\n"),
    ].join("\n---\n")

    llm = LangchainrbRails.config.vectorsearch.llm
    llm.chat(
      messages: [
        { role: "system", content: "You are Nosia, a helpful assistant. You will be given a context and a question.\nYour task is to provide a 'note' scoring how well one can answer the given question unambiguously with the given context.\nGive your answer on a scale of 1 to 5, where 1 means that the question is not answerable at all given the context, and 5 means that the question is clearly and unambiguously answerable with the context.\n\nProvide your answer in the language of the question and as follows:\n\nEvaluation: (your rationale for the note, as a text in the language of the question)\nNote: (your note, as a number between 1 and 5) / 5\nResponse: (your response to the question, as a text in the language of the question)\n\nYou MUST provide values for 'Evaluation' and 'Note' in your answer." },
        { role: "user", content: prompt }
      ]
   ) do |stream|
      new_content = stream.raw_response.dig("message", "content")
      message.update(content: message.content + new_content) if new_content
    end
  end
end
