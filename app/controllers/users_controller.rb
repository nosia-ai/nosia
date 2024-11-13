# frozen_string_literal: true

class UsersController < ApplicationController
  def new
  end

  def create
    @user = User.where("lower(email) = ?", user_params[:email]).first
    @user ||= User.new(user_params)

    # Make the first user admin in development environment
    if Rails.env.development? && User.all.count.eql?(0)
      @user.admin = true
    end

    if @user.save
      @session = create_passwordless_session(@user)

      Passwordless.config.after_session_save.call(@session, request)

      if Rails.env.development?
        notice = "Email sent! Go to /mailbin in development environment to see your token!"
      else
        notice = "Email sent!"
      end

      redirect_to(
        Passwordless.context.path_for(
          @session,
          id: @session.to_param,
          action: "show",
          **default_url_options
        ), flash: { notice: }
      )
    else
      render(:new)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
