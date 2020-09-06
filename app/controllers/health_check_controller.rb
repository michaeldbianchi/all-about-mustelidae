class HealthCheckController < ApplicationController
  def health
    render json: {status: :ok}
  end
end
