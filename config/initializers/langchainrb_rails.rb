# frozen_string_literal: true

Faraday.default_connection_options = Faraday::ConnectionOptions.new({
  timeout: 240,
})

LangchainrbRails.configure do |config|
  config.vectorsearch = Langchain::Vectorsearch::Pgvector.new(
    llm: Langchain::LLM::Ollama.new(
      url: ENV["OLLAMA_URL"] || "http://localhost:11434",
      default_options: {
        completion_model_name: ENV["OLLAMA_MODEL"] || "llama3",
        embeddings_model_name: ENV["OLLAMA_MODEL"] || "llama3",
        chat_completion_model_name: ENV["OLLAMA_MODEL"] || "llama3",
      }
    )
  )
end
