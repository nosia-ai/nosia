# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ApplicationController
      allow_unauthenticated_access
      skip_before_action :verify_authenticity_token
      before_action :verify_api_key

      private

      def verify_api_key
        authenticate_or_request_with_http_token do |token, _options|
          api_token = ApiToken.find_by(token:)
          @account = api_token&.account
          @user = api_token&.user
        end
      end
    end
  end
end
