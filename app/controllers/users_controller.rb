# frozen_string_literal: true

class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # Make the first user admin
    @user.admin = true if User.all.count.eql?(0)

    if @user.save
      user = User.find_by(email: user_params[:email])&.authenticate(user_params[:password])
      start_new_session_for user
      redirect_to root_path, notice: "Welcome to Nosia!"
    else
      redirect_to root_path, alert: "Try another email address or password with at least 12 characters."
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
