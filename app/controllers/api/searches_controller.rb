class Api::SearchesController < ApplicationController
  def create
    if valid_params?
      client = Boomnow::Client.new
      results = client.search(city: search_params[:city], adults: search_params[:adults])
      render json: results, status: :ok
    else
      render json: { errors: validation_errors }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { errors: [e.message] }, status: :internal_server_error
  end

  private

  def search_params
    # Handle both nested (Rails wrapped) and top-level params
    if params[:search].present?
      params.require(:search).permit(:city, :adults)
    else
      params.permit(:city, :adults)
    end
  end

  def valid_params?
    validation_errors.empty?
  end

  def validation_errors
    errors = []
    errors << "City is required" if search_params[:city].blank?
    errors << "Adults is required" if search_params[:adults].blank?
    
    if search_params[:adults].present?
      adults = search_params[:adults].to_i
      errors << "Adults must be a positive integer" if adults <= 0 || !search_params[:adults].to_s.match?(/^\d+$/)
    end
    
    errors
  end
end

