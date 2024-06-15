class MessagesController < ApplicationController
  include ActionView::RecordIdentifier

  def create
    @message = Message.create(message_params.merge(chat_id: params[:chat_id], role: "user"))
    GetAiResponseJob.perform_later(@message.chat_id)

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
