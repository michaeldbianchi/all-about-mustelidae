class HealthCheckController < ApplicationController
  def health
    render json: { status: :ok, time: Time.now.utc.iso8601 }
  end
end
