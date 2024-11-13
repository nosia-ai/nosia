class ChatsController < ApplicationController
  before_action :set_chat, only: %i[show destroy]

  def show
  end

  def create
    @chat = current_user.chats.create
    redirect_to @chat
  end

  def destroy
    @chat.destroy
    redirect_to root_path
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:id])
  end
end
