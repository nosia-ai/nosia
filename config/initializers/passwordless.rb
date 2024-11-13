Passwordless.configure do |config|
  config.default_from_address = Rails.application.credentials.dig(:smtp, :mail_from)
  config.parent_controller = "ApplicationController"
  config.parent_mailer = "ActionMailer::Base"
  config.restrict_token_reuse = true # Can a token/link be used multiple times?
  config.token_generator = Passwordless::ShortTokenGenerator.new # Used to generate magic link tokens.

  config.expires_at = lambda { 1.year.from_now } # How long until a signed in session expires.
  config.timeout_at = lambda { 10.minutes.from_now } # How long until a token/magic link times out.

  config.redirect_back_after_sign_in = true # When enabled the user will be redirected to their previous page, or a page specified by the `destination_path` query parameter, if available.
  config.redirect_to_response_options = {} # Additional options for redirects.
  config.success_redirect_path = "/" # After a user successfully signs in
  config.failure_redirect_path = "/" # After a sign in fails
  config.sign_out_redirect_path = "/" # After a user signs out

  config.paranoid = true # Display email sent notice even when the resource is not found.

  config.after_session_confirm = ->(request, session) { } # Called after a session is confirmed.
end
