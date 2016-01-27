class PhoneCallbacksController < ApplicationController
  before_action :authenticate_or_forbid, only: [:index, :show, :destroy, :close]
  before_action :fetch_callback, only: [:show, :close, :destroy]

  def new
    @callback = PhoneCallback.new
  end

  def create
    @callback = PhoneCallback.new(callback_params)
    if @callback.save
      redirect_to root_path
    else
      flash.now[:alert] = t 'flash.create.alert'
      render :new
    end
  end

  def destroy
    if @callback.destroy
      redirect_to phone_callbacks_path
    else
      flash.now[:alert] = t 'flash.destroy.alert'
      redirect_to phone_callbacks_path
    end
  end

  def close
    if @callback.close
      redirect_to phone_callbacks_path
    else
      flash.now[:alert] = t 'flash.update.alert'
      redirect_to phone_callbacks_path
    end
  end

  def index
    @callbacks = PhoneCallback.order('created_at DESC')
    .paginate(page: params[:page], per_page: 15)
  end

  private

  def fetch_callback
    @callback = PhoneCallback.find(params[:id])
  end

  def callback_params
    params.require(:phone_callback).permit(:name, :phone)
  end
end
