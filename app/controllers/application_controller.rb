class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  force_ssl if Rails.env.production?
  before_action :fetch_unread_count
  before_action :fetch_pending_callbacks_count

  protected

  def authenticate_or_forbid
    if current_admin
      true
    else
      render json: { status: :forbidden }, status: 403
    end
  end

  def fetch_unread_count
    if current_admin
      @unread_messages = Contact.where(unread: true).count
    end
  end

  def fetch_pending_callbacks_count
    if current_admin
      @pending_callbacks = PhoneCallback.where(pending: true).count
    end
  end
end
