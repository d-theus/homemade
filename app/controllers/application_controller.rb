class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  force_ssl if Rails.env.production?

  protected

  def authenticate_or_forbid
    if current_admin
      true
    else
      render json: { status: :forbidden }, status: 403
    end
  end
end
