class FactsController < ApplicationController
  def index
    render json: {ping: "pong"}
  end
end
