module Chat::Ollama
  extend ActiveSupport::Concern

  class_methods do
    def new_ollama_llm
      Langchain::LLM::OpenAI.new(
        api_key: ENV.fetch("OLLAMA_API_KEY", ""),
        llm_options: {
          uri_base: ENV.fetch("OLLAMA_BASE_URL", "http://localhost:11434")
        },
        default_options: {
          chat_completion_model_name: ENV.fetch("LLM_MODEL", "qwen2.5"),
          completion_model_name: ENV.fetch("LLM_MODEL", "qwen2.5"),
          embeddings_model_name: ENV.fetch("EMBEDDING_MODEL", "nomic-embed-text"),
          temperature: ENV.fetch("LLM_TEMPERATURE", 0.1).to_f,
          num_ctx: ENV.fetch("LLM_NUM_CTX", 4_096).to_i
        }
      )
    end

    def new_ollama_check_llm
      Langchain::LLM::Ollama.new(
        url: ENV.fetch("OLLAMA_BASE_URL", "http://localhost:11434"),
        api_key: ENV.fetch("OLLAMA_API_KEY", ""),
        default_options: {
          chat_completion_model_name: ENV.fetch("CHECK_MODEL", "bespoke-minicheck"),
          completion_model_name: ENV.fetch("CHECK_MODEL", "bespoke-minicheck"),
          temperature: ENV.fetch("LLM_TEMPERATURE", 0.1).to_f,
          num_ctx: ENV.fetch("LLM_NUM_CTX", 2_048).to_i
        }
      )
    end
  end

  def complete_with_ollama(top_k:, top_p:, &block)
    question = last_question

    context = []

    assistant_response = messages.create(role: "assistant", done: false, content: "", response_number:)
    assistant_response.broadcast_created

    messages_for_assistant = []
    messages_for_assistant << { role: "system", content: system_prompt }
    messages_for_assistant << messages_hash if messages_hash.any?

    checked_chunks = []

    check_llm = Chat.new_ollama_check_llm

    search_results = Chunk.where(account:).similarity_search(question, k: retrieval_fetch_k)
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

    if checked_chunks.any?
      assistant_response.update(similar_document_ids: checked_chunks.pluck(:document_id).uniq)

      context << checked_chunks.map(&:content).join("\n\n")
      context = context.join("\n\n")

      prompt = ENV.fetch("QUERY_PROMPT_TEMPLATE", "Nosia helpful content: {context}\n\n---\n\nNow here is the question you need to answer.\n\nQuestion: {question}")
      prompt = prompt.gsub("{context}", context)
      prompt = prompt.gsub("{question}", question)

      messages_for_assistant.pop
      messages << { role: "user", content: prompt }
    end

    messages_for_assistant = messages_for_assistant.flatten

    llm = Chat.new_ollama_llm
    llm_response = llm.chat(messages:, top_k:, top_p:, &block)

    assistant_response.update(done: true, content: llm_response.completion)
    assistant_response
  end
end
