class MatchResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # NOTE: this is unused because we are sending match results back synchronously
  def create
    match_results = params[:match_results]

    MatchResultProcessor.process(match_results)

    render json: { message: "Match results processed successfully" }, status: :ok
  end
end