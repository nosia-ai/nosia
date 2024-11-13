class User < ApplicationRecord
  has_many :chats, dependent: :destroy
  has_many :credentials, dependent: :destroy

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  passwordless_with :email
end
