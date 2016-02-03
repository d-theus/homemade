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
    @sub = WeeklyMenuSubscription.find(params[:id])

    if @sub.token != params[:token]
      render json: { status: 'error', message: 'unauthorized' }, status: :unauthorized
      return
    end

    if @sub.destroy
      respond_to do |f|
        f.html { render :unsubscribed }
        f.json { render nothing: true, status: :ok }
      end
    else
      respond_to do |f|
        f.json { render json: { status: 'error', message: @sub.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def unsubscribed
  end

  def show
    @recipes = Recipe.featured
    @sub = WeeklyMenuSubscription.find(params[:id])
    respond_to do |f|
      f.html
    end
  end

  private

  def subscription_params
    params.require(:weekly_menu_subscription).permit(:email)
  end
end
