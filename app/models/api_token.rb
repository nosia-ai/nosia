class ApiToken < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_secure_token :token

  validates :name, presence: true
end
