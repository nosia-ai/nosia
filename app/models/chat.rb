class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy

  def last_question
    messages.where(role: "user").order(:created_at).last.content
  end
end
