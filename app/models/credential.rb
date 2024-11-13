class Credential < ApplicationRecord
  belongs_to :user, validate: true

  validates :provider, presence: true
  validates :uid, presence: true
end
