require 'rails_helper'

RSpec.describe RecipesController, type: :controller do
  let(:json) { JSON.parse! response.body }
  describe 'index' do
    before(:all) { Recipe.delete_all }
    before(:all) { 100.times { FactoryGirl.create(:recipe) } }

    it_requires_authentication :get, :index

    context 'authorized' do
      before { sign_in }
      before { get :index }

      it 'renders template' do
        expect(response).to render_template(:index)
      end

      it 'result is paginated' do
        expect(assigns(:recipes).size).to be <= 25
      end
    end
  end

  describe 'show' do
    context 'not authorized' do
      before { sign_in nil }
      before { get :show, id: Recipe.first.id, format: :json }
      it 'grants access' do
        expect(response).to have_http_status(:success)
      end

      it 'response is one recipe' do
        expect(json).to have_key('recipe')
        expect(json['recipe'].keys).to include('id', 'title', 'subtitle', 'cooking_time', 'calories', 'inventory_items', 'url')
        expect(json['recipe'].keys).not_to include('edit_url')
        expect(json['recipe']['id']).not_to be_nil
      end
    end
  end

  describe 'new' do
    it_requires_authentication :get, :new

    context 'authorized' do
      before { sign_in }
      before { get :new }

      it 'returns :ok' do
        expect(response).to have_http_status(:success)
      end

      it 'renders html template' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'create' do
    it_requires_authentication :post, :create

    context 'authorized' do
      before { sign_in }

      context 'with valid recipe' do
        let(:req) { post :create, recipe: FactoryGirl.attributes_for(:recipe) }

        it 'returns :ok' do
          req()
          expect(response).to have_http_status :ok
        end

        it 'creates a recipe' do
          expect {req()}.to change(Recipe, :count).by(1)
        end
      end

      context 'with invalid recipe' do
        before { post :create, recipe: FactoryGirl.attributes_for(:recipe, title: '') }

        it 'returns :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'has errors' do
          expect(json).to have_key('errors')
          expect(json['errors']).to have_key('title')
        end
      end
      context 'with bad params' do
        it 'returns :bad_request' do
          expect {
            post :create,
            bad_bad: FactoryGirl.attributes_for(:recipe)
          }.to raise_error ActionController::ParameterMissing
        end
      end
    end
  end

  describe 'edit' do
    it_requires_authentication :get, :edit, id: Recipe.first.id

    context 'authorized' do
      before { sign_in }
      before { get :edit, id: Recipe.first.id }

      it 'has status :ok' do
        expect(response).to have_http_status :ok
      end

      it 'assigns @recipe' do
        expect(assigns(:recipe)).not_to be_nil
        expect(assigns(:recipe).id).not_to be_nil
      end
    end
  end

  describe 'update' do
    it_requires_authentication :put, :update, id: Recipe.first.id

    context 'authorized' do
      before { sign_in }

      context 'with valid recipe' do
        let(:req) { put :update, id: Recipe.first.id, recipe: { title: 'Updated'} }
        it 'returns :ok' do
          req()
          expect(response).to have_http_status :ok
        end
        it 'changes a recipe' do
          expect { req()}.to change {Recipe.first.title}.from(Recipe.first.title).to('Updated')
        end
      end
      context 'with invalid recipe' do
        before { put :update, id: Recipe.first.id, recipe: { title: ''} }

        it 'returns :unprocessable_entity' do
           expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'has errors' do
          expect(json).to have_key('errors')
          expect(json['errors']).to have_key('title')
        end
      end
      context 'with bad params' do
        it 'returns :bad_request' do
           expect{
           put :update, id: Recipe.first.id, bad_bad: { title: ''} 
           }.to raise_error ActionController::ParameterMissing
        end
      end
    end
  end

  describe 'destroy' do
    it_requires_authentication :delete, :destroy, id: Recipe.first.id, format: :json

    context 'authorized' do
      before { sign_in }

      context 'if recipe belongs to week recipes' do
        it 'cannot be deleted'
        it 'has errors'
      end

      context 'if recipe does not belong to week' do
        let(:req) { delete :destroy, id: Recipe.first, format: :json }
        it 'returns :ok' do
          req()
          expect(response).to have_http_status(:ok)
        end
        it 'is deleted' do
          expect {req()}.to change(Recipe, :count).by(-1)
        end
      end
    end
  end
end
