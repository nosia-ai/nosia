class User < ApplicationRecord
  has_secure_password

  has_many :chats, dependent: :destroy
  has_many :credentials, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, presence: true, length: { minimum: 12 }
end
