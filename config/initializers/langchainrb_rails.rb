# frozen_string_literal: true

Faraday.default_connection_options = Faraday::ConnectionOptions.new({
  timeout: 240
})

LangchainrbRails.configure do |config|
  config.vectorsearch = Langchain::Vectorsearch::Pgvector.new(
    llm: Langchain::LLM::Ollama.new(
      url: ENV.fetch("OLLAMA_BASE_URL", "http://:11434"),
      api_key: ENV.fetch("OLLAMA_API_KEY", ""),
      default_options: {
        chat_completion_model_name: ENV.fetch("LLM_MODEL", "qwen2.5"),
        completion_model_name: ENV.fetch("LLM_MODEL", "qwen2.5"),
        embeddings_model_name: ENV.fetch("EMBEDDING_MODEL", "nomic-embed-text"),
        temperature: ENV.fetch("LLM_TEMPERATURE", 0.1).to_f,
        num_ctx: ENV.fetch("LLM_NUM_CTX", 4_096).to_i
      }
    )
  )
end
