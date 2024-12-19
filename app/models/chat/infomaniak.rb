module Chat::Infomaniak
  extend ActiveSupport::Concern

  class_methods do
    def new_infomaniak_llm(model: ENV.fetch("LLM_MODEL", "mixtral"))
      Langchain::LLM::OpenAI.new(
        api_key: ENV.fetch("INFOMANIAK_API_KEY", ""),
        llm_options: {
          api_type: :infomaniak,
          uri_base: "https://api.infomaniak.com/1/ai/#{ENV.fetch("INFOMANIAK_PRODUCT_ID", "")}/openai"
        },
        default_options: {
          chat_completion_model_name: model,
          completion_model_name: model,
          embeddings_model_name: ENV.fetch("EMBEDDING_MODEL", "bge_multilingual_gemma2"),
          temperature: ENV.fetch("LLM_TEMPERATURE", 0.1).to_f,
          num_ctx: ENV.fetch("LLM_NUM_CTX", 4_096).to_i
        }
      )
    end
  end

  def complete_with_infomaniak(model:, temperature:, top_p:, max_tokens:, &block)
    question = last_question

    context = []

    messages_for_assistant = []
    messages_for_assistant << { role: "system", content: system_prompt }
    messages_for_assistant << messages_hash if messages_hash.any?

    assistant_response = messages.create(role: "assistant", done: false, content: "", response_number:)
    assistant_response.broadcast_created

    retrieved_chunks = Chunk.where(account:).similarity_search(question, k: retrieval_fetch_k)
    assistant_response.update(similar_document_ids: retrieved_chunks.pluck(:chunkable_id).uniq) if retrieved_chunks.any?

    if retrieved_chunks.any?
      context << retrieved_chunks.map(&:content).join("\n\n")
      context = context.join("\n\n")

      prompt = ENV.fetch("QUERY_PROMPT_TEMPLATE", "Nosia helpful content: {context}\n\n---\n\nNow here is the question you need to answer.\n\nQuestion: {question}")
      prompt = prompt.gsub("{context}", context)
      prompt = prompt.gsub("{question}", question)

      messages_for_assistant.pop
      messages_for_assistant << { role: "user", content: prompt }
    end

    messages_for_assistant = messages_for_assistant.flatten

    llm = Chat.new_infomaniak_llm(model:)
    llm_response = llm.chat(messages: messages_for_assistant, temperature:, top_p:, max_tokens:, &block)

    assistant_response.update(done: true, content: llm_response.completion)
    assistant_response
  end
end
