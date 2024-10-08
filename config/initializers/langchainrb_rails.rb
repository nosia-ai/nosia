# frozen_string_literal: true

Faraday.default_connection_options = Faraday::ConnectionOptions.new({
  timeout: 240,
})

LangchainrbRails.configure do |config|
  config.vectorsearch = Langchain::Vectorsearch::Pgvector.new(
    llm: Langchain::LLM::Ollama.new(
      url: ENV.fetch("OLLAMA_URL", "http://localhost:11434"),
      default_options: {
        chat_completion_model_name: ENV.fetch("OLLAMA_CHAT_COMPLETION_MODEL", "phi3:medium"),
        completion_model_name: ENV.fetch("OLLAMA_COMPLETION_MODEL", "phi3:medium"),
        embeddings_model_name: ENV.fetch("OLLAMA_EMBEDDINGS_MODEL", "nomic-embed-text"),
        temperature: 0.1,
      }
    )
  )
end
