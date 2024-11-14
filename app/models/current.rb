class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :impersonated_user

  def user = true_user
  def true_user = session&.user
end
