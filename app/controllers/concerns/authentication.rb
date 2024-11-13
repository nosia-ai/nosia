# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  include Passwordless::ControllerHelpers

  included do
    helper_method :current_user
  end

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  private

  def require_user!
    return if current_user
    save_passwordless_redirect_location!(User)
    redirect_to users_sign_in_path, alert: "You are not worthy!"
  end
end
