# frozen_string_literal: true

class ApiTokensController < ApplicationController
  def index
    @api_tokens = Current.user.api_tokens
  end

  def create
    @api_token = Current.user.api_tokens.new(api_token_params)

    if @api_token.save
      redirect_to api_tokens_path
    else
      redirect_to api_tokens_path, alert: "An error occured."
    end
  end

  def destroy
    @api_token = Current.user.api_tokens.find(params[:id])
    @api_token.destroy
    redirect_to api_tokens_path
  end

  private

  def api_token_params
    params.require(:api_token).permit(:name)
  end
end
