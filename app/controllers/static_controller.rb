# frozen_string_literal: true

class StaticController < ApplicationController
  allow_unauthenticated_access only: [ :index ]

  def index
  end
end
