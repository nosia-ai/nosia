class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"

  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :chunks
  has_many :documents, dependent: :destroy
end
