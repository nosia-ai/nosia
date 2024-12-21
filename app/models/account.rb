class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"

  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :chats, dependent: :destroy
  has_many :chunks, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :qnas, dependent: :destroy
  has_many :texts, dependent: :destroy
  has_many :websites, dependent: :destroy

  def context
    context = []
    context << texts.map(&:context)
    context << qnas.map(&:context)
    context << documents.map(&:context)
    context << websites.map(&:context)
    context.join("\n\n")
  end
end
