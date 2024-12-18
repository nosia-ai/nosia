# frozen_string_literal: true

module Api
  module V1
    class CompletionsController < ApplicationController
      include ActionController::Live

      def create
        account = @user.accounts.find_or_create_by(uid: completion_params[:user]) if completion_params[:user].present?
        account ||= @account

        @chat = @user.chats.create(account:)

        if completion_params[:messages].present?
          completion_params[:messages].each do |message_params|
            @chat.messages.create(
              content: message_params[:content],
              response_number: @chat.messages.count,
              role: message_params[:role]
            )
          end
        elsif completion_params[:prompt].present?
          @chat.messages.create(
            content: message_params[:prompt],
            response_number: @chat.messages.count,
            role: "user"
          )
        end

        stream_response = ActiveModel::Type::Boolean.new.cast(params[:stream]) || false

        if stream_response
          chat_response = @chat.complete do |stream|
            stream_content = stream.dig("delta", "content")
            next unless stream_content
            done = !!stream.dig("finish_reason")
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
                id: "chatcmpl-#{@chat.id}",
                model: "nosia:#{ENV["LLM_MODEL"]}",
                object: "chat.completion.chunk",
                system_fingerprint: "fp_nosia"
              }
              response.stream.write("data: #{data.to_json}\n\n")
            end
          end
        else
          chat_response = @chat.complete
          render json: {
            choices: [
              finish_reason: "stop",
              index: 0,
              message: {
                content: chat_response.content,
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
      ensure
        response.stream.close if response.stream.respond_to?(:close)
      end

      private

      def completion_params
        params.permit(
          :max_tokens,
          :model,
          :prompt,
          :stream,
          :top_p,
          :top_k,
          :temperature,
          :user,
          messages: [
            :content,
            :role
          ],
          stop: [],
          chat: {},
          completion: {},
        )
      end
    end
  end
end
