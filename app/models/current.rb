class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :impersonated_user

  def account = user.first_account
  def user = true_user
  def true_user = session&.user
end
