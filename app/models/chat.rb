class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy

  def first_question
    messages.where(role: "user").order(:created_at).first&.content
  end

  def last_question
    messages.where(role: "user").order(:created_at).last&.content
  end

  def messages_hash
    messages.order(:response_number).map do |message|
      {
        role: message.role,
        content: message.content
      }
    end
  end
end
