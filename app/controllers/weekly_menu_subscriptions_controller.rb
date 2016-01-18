class WeeklyMenuSubscriptionsController < ApplicationController
  respond_to :json

  def create
    @sub = WeeklyMenuSubscription.new(subscription_params)
    if @sub.save
      render nothing: true, status: :ok
    else
      render json: { status: 'error', message: @sub.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @sub.destroy
      render :unsubscribed
    else
      render json: { status: 'error', message: @sub.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def unsubscribed
  end

  private

  def subscription_params
    params.require(:weekly_menu_subscription).permit(:email)
  end
end
