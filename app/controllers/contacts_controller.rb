class ContactsController < ApplicationController
  before_action :authenticate_or_forbid, only: [:index, :show, :destroy]
  before_action :fetch_contact, only: [:show, :read, :destroy]

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to root_path
    else
      flash.now[:alert] = t 'flash.create.alert'
      render :new
    end
  end

  def destroy
    if @contact.destroy
      redirect_to contacts_path
    else
      flash.now[:alert] = t 'flash.destroy.alert'
      render :show
    end
  end

  def read
    if @contact.read
      redirect_to contacts_path
    else
      flash.now[:alert] = t 'flash.update.alert'
      redirect_to contacts_path
    end
  end

  def show
    @contact.read
  end

  def index
    @contacts = Contact.order('created_at DESC')
    .paginate(page: params[:page], per_page: 15)
  end

  private

  def fetch_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:email, :topic, :text, :name)
  end
end
