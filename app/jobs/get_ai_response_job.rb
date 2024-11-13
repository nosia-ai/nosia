class GetAiResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id)
    chat = Chat.find(chat_id)
    call_ollama(chat:)
  end

  private

  def create_message(chat:)
    response_number = chat.messages.count
    message = chat.messages.create(role: "assistant", content: "", response_number:)
    message.broadcast_created
    message
  end

  def call_ollama(chat:)
    top_k = ENV.fetch("LLM_TOP_K", 40).to_f
    top_p = ENV.fetch("LLM_TOP_P", 0.9).to_f

    message = create_message(chat:)

    question = chat.last_question

    check_llm = Langchain::LLM::Ollama.new(
      url: ENV.fetch("OLLAMA_BASE_URL", "http://127.0.0.1:11434"),
      api_key: ENV.fetch("OLLAMA_API_KEY", ""),
      default_options: {
        chat_completion_model_name: ENV.fetch("CHECK_MODEL", "bespoke-minicheck"),
        completion_model_name: ENV.fetch("CHECK_MODEL", "bespoke-minicheck"),
        temperature: ENV.fetch("LLM_TEMPERATURE", 0.1).to_f,
        num_ctx: ENV.fetch("LLM_NUM_CTX", 2_048).to_i
      }
    )

    checked_chunks = []

    search_results = Chunk.similarity_search(question, k: ENV.fetch("RETRIEVAL_FETCH_K", 4))
    search_results.each do |search_result|
      context_to_check = search_result.content

      check_message = [
        { role: "user", content: "Document: #{context_to_check}\nClaim: #{question}" }
      ]

      check_llm.chat(messages: check_message, top_k:, top_p:) do |stream|
        check_response = stream.raw_response.dig("message", "content")

        if check_response.eql?("Yes")
          checked_chunks << search_result
        end
      end
    end

    llm = LangchainrbRails.config.vectorsearch.llm
    context = []

    messages = []
    messages << { role: "system", content: ENV.fetch("RAG_SYSTEM_TEMPLATE", "You are Nosia. You are a helpful assistant.") }
    messages << chat.messages_hash if chat.messages_hash.any?

    if checked_chunks.any?
      message.update(similar_document_ids: checked_chunks.pluck(:document_id).uniq)

      context << checked_chunks.map(&:content).join("\n\n")
      context = context.join("\n\n")

      prompt = ENV.fetch("QUERY_PROMPT_TEMPLATE", "Nosia helpful content: {context}\n\n---\n\nNow here is the question you need to answer.\n\nQuestion: {question}")
      prompt = prompt.gsub("{context}", context)
      prompt = prompt.gsub("{question}", question)

      messages << { role: "user", content: prompt }
    else
      messages << { role: "user", content: question }
    end

    messages = messages.flatten

    llm.chat(messages:, top_k:, top_p:) do |stream|
      new_content = stream.raw_response.dig("message", "content")
      message.update(content: message.content + new_content) if new_content
    end
  end
end
