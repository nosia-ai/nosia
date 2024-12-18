module Chat::Completionable
  extend ActiveSupport::Concern

  class_methods do
    def ai_provider
      ENV.fetch("AI_PROVIDER", "ollama")
    end
  end

  def complete(&block)
    case Chat.ai_provider
    when "ollama"
      complete_with_ollama(&block)
    when "infomaniak"
      complete_with_infomaniak(&block)
    end
  end

  private

  def retrieval_fetch_k
    ENV.fetch("RETRIEVAL_FETCH_K", 4)
  end

  def system_prompt
    ENV.fetch("RAG_SYSTEM_TEMPLATE", "You are Nosia. You are a helpful assistant.")
  end

  def top_k
    ENV.fetch("LLM_TOP_K", 40).to_f
  end

  def top_p
    ENV.fetch("LLM_TOP_P", 0.9).to_f
  end
end
