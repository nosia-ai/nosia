module Chat::Completionable
  extend ActiveSupport::Concern

  class_methods do
    def ai_provider
      ENV.fetch("AI_PROVIDER", "ollama")
    end
  end

  def complete(model: nil, temperature: nil, top_k: nil, top_p: nil, max_tokens: nil, &block)
    max_tokens ||= ENV.fetch("LLM_MAX_TOKENS", 1_024).to_i
    model ||= ENV.fetch("LLM_MODEL", "mixtral")
    temperature ||= ENV.fetch("LLM_TEMPERATURE", 0.1).to_f
    top_k ||= ENV.fetch("LLM_TOP_K", 40).to_f
    top_p ||= ENV.fetch("LLM_TOP_P", 0.9).to_f

    case Chat.ai_provider
    when "ollama"
      complete_with_ollama(top_k:, top_p:, &block)
    when "infomaniak"
      complete_with_infomaniak(model:, temperature:, top_p:, max_tokens:, &block)
    end
  end

  private

  def retrieval_fetch_k
    ENV.fetch("RETRIEVAL_FETCH_K", 4)
  end

  def system_prompt
    ENV.fetch("RAG_SYSTEM_TEMPLATE", "You are Nosia. You are a helpful assistant.")
  end
end
