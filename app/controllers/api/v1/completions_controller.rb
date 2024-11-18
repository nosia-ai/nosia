# frozen_string_literal: true

module Api
  module V1
    class CompletionsController < ApplicationController
      include ActionController::Live

      allow_unauthenticated_access only: [ :create ]
      skip_before_action :verify_authenticity_token
      before_action :verify_api_key
      before_action :parse_params, only: [ :create ]

      def create
        @llm = LangchainrbRails.config.vectorsearch.llm
        @uuid = SecureRandom.uuid

        if @stream
          stream_response
        else
          non_stream_response
        end
      rescue StandardError => e
        handle_error(e)
      end

      private

      def build_check_llm
        Langchain::LLM::Ollama.new(
          url: ENV.fetch("OLLAMA_BASE_URL", "http://localhost:11434"),
          api_key: ENV.fetch("OLLAMA_API_KEY", ""),
          default_options: {
            chat_completion_model_name: ENV.fetch("CHECK_MODEL", "bespoke-minicheck"),
            completion_model_name: ENV.fetch("CHECK_MODEL", "bespoke-minicheck"),
            temperature: ENV.fetch("LLM_TEMPERATURE", 0.1).to_f,
            num_ctx: ENV.fetch("LLM_NUM_CTX", 4_096).to_i
          }
        )
      end

      def build_context(checked_chunks)
        checked_chunks.map(&:content).join("\n")
      end

      def build_messages(question, context)
        system_message = {
          role: "system",
          content: ENV.fetch("RAG_SYSTEM_TEMPLATE", "You are Nosia. You are a helpful assistant.")
        }

        user_content = if context.present?
          template = ENV.fetch(
            "QUERY_PROMPT_TEMPLATE",
            "Nosia helpful content: {context}\n\n---\n\nNow here is the question you need to answer.\n\nQuestion: {question}"
          )
          template.gsub("{context}", context).gsub("{question}", question)
        else
          question
        end

        user_message = { role: "user", content: user_content }

        [ system_message, user_message ]
      end

      def check_context(question)
        k = ENV.fetch("RETRIEVAL_FETCH_K", 4)

        check_llm = build_check_llm
        checked_chunks = []

        search_results = Chunk.similarity_search(question, k:)
        search_results.each do |search_result|
          context_to_check = search_result.content
          check_message = [ { role: "user", content: "Document: #{context_to_check}\nClaim: #{question}" } ]

          check_llm.chat(messages: check_message, top_k: @top_k, top_p: @top_p) do |stream|
            check_response = stream.raw_response.dig("message", "content")

            if check_response && check_response.eql?("Yes")
              checked_chunks << search_result
            end
          end
        end

        checked_chunks
      rescue StandardError => e
        handle_error(e)
        []
      end

      def handle_error(e)
        error_message = {
          error: {
            message: e.message,
            backtrace: Rails.env.development? ? e.backtrace : nil
          }
        }

        if @stream
          response.stream.write("data: #{error_message.to_json}\n\n")
          response.stream.write("data: [DONE]\n\n")
        else
          render json: error_message, status: :internal_server_error
        end
      ensure
        response.stream.close if @stream
      end

      def non_stream_response
        checked_chunks = check_context(@question)
        context = build_context(checked_chunks)
        messages = build_messages(@question, context)

        content = ""
        data = {}

        @llm.chat(messages:, top_k: @top_k, top_p: @top_p) do |stream|
          stream_content = stream.raw_response.dig("message", "content")
          content += stream_content if stream_content

          done = !!stream.raw_response["done"]

          if done
            data = {
              choices: [
                finish_reason: "stop",
                index: 0,
                message: {
                  content: content,
                  role: "assistant"
                }
              ],
              created: Time.now.to_i,
              id: "chatcmpl-#{@uuid}",
              model: "nosia:#{ENV["LLM_MODEL"]}",
              object: "chat.completion",
              system_fingerprint: "fp_nosia"
            }
          end
        end

        render json: data
      end

      def parse_params
        params.permit(
          :max_tokens,
          :model,
          :prompt,
          :stream,
          :top_p,
          :top_k,
          :temperature,
          messages: [
            :content,
            :role
          ],
          stop: [],
          chat: {},
          completion: {},
        )

        @question = params[:prompt] || params.dig(:messages, 0, :content)
        @stream = ActiveModel::Type::Boolean.new.cast(params[:stream]) || false
        @top_p = params[:top_p].to_f || ENV.fetch("LLM_TOP_P", 0.9).to_f
        @top_k = params[:top_k].to_i || ENV.fetch("LLM_TOP_K", 40)
      end

      def stream_response
        checked_chunks = check_context(@question)
        context = build_context(checked_chunks)
        messages = build_messages(@question, context)

        response.headers["Content-Type"] = "text/event-stream"

        @llm.chat(messages:, top_k: @top_k, top_p: @top_p) do |stream|
          stream_content = stream.raw_response.dig("message", "content")
          next unless stream_content

          done = !!stream.raw_response["done"]

          if done
            response.stream.write("data: [DONE]\n\n")
          else
            data = {
              choices: [
                delta: {
                  content: stream_content,
                  role: "assistant"
                },
                finish_reason: done ? "stop" : nil,
                index: 0
              ],
              created: Time.now.to_i,
              id: "chatcmpl-#{@uuid}",
              model: "nosia:#{ENV["LLM_MODEL"]}",
              object: "chat.completion.chunk",
              system_fingerprint: "fp_nosia"
            }

            response.stream.write("data: #{data.to_json}\n\n")
          end
        end
      ensure
        response.stream.close if response.stream.respond_to?(:close)
      end

      def verify_api_key
        authenticate_or_request_with_http_token do |token, _options|
          api_token = ApiToken.find_by(token:)
          @user = api_token&.user
        end
      end
    end
  end
end
