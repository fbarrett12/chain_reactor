class StatusController < ApplicationController
  def index
    render json: {
      name: "Chain Reactor EDI Normalizer API",
      status: "running"
    }
  end

  def health
    render json: { status: "ok" }
  end
end
