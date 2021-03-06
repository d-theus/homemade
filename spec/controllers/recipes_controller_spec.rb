require 'rails_helper'

RSpec.describe RecipesController, type: :controller do
  let(:json) { JSON.parse! response.body }
  before(:all) { Recipe.delete_all }
  before(:all) { 100.times { FactoryGirl.create(:recipe) } }

  describe '#index' do
    it_requires_authentication :get, :index

    context 'authorized' do
      before { sign_in }
      before { get :index }

      it 'renders template' do
        expect(response).to render_template(:index)
      end

      it 'result is paginated' do
        expect(assigns(:recipes).size).to be <= 18
      end
    end
  end

  describe '#show' do
    context 'not authorized' do
      before { sign_in nil }
      before { get :show, id: Recipe.first.id }
      it 'grants access' do
        expect(response).to have_http_status(:success)
      end

      it 'responds with html' do
        expect(response.header['Content-Type']).to match(/html/)
      end

      it 'assigns @recipe' do
        expect(assigns(:recipe)).to be_a Recipe
      end
    end
  end

  describe '#new' do
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

      it 'assigns @recipe' do
        expect(assigns(:recipe)).not_to be_nil
      end
    end
  end

  describe '#create' do
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

  describe '#edit' do
    it_requires_authentication :get, :edit, id: (FactoryGirl.create(:recipe)).id

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

  describe '#update' do
    it_requires_authentication :put, :update, id: Recipe.first.id

    context 'authorized' do
      before { sign_in }

      context 'with valid recipe' do
        let(:req) { put :update, id: Recipe.first.id, recipe: { title: 'Updated'} }
        it 'redirects to recipe' do
          req()
          expect(response).to redirect_to(recipe_path(Recipe.first.id))
        end
        it 'changes a recipe' do
          expect { req()}.to change {Recipe.first.title}.from(Recipe.first.title).to('Updated')
        end
      end
      context 'with invalid recipe' do
        context 'with invalid title' do
          before { put :update, id: Recipe.first.id, recipe: { title: ''} }

          it 'returns :unprocessable_entity' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'has errors' do
            expect(assigns(:recipe)).to respond_to(:errors)
            expect(assigns(:recipe).errors).to have_key(:title)
          end
        end

        context 'with invalid day' do
          before { put :update, id: Recipe.offset(1).first.id, recipe: { day: 1} }
          before { put :update, id: Recipe.offset(2).first.id, recipe: { day: 1 } }

          it 'returns :unprocessable_entity' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'has errors' do
            expect(assigns(:recipe)).to respond_to(:errors)
            expect(assigns(:recipe).errors).to have_key(:day)
          end
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

  describe '#destroy' do
    let(:recipe) { FactoryGirl.create(:recipe)}
    let(:req) { delete :destroy, id: recipe.id, format: :json }

    context 'unauthorized' do
      it 'returns 403' do
        delete :destroy, id: recipe.id, format: :json
      end
    end

    context 'authorized' do
      before { sign_in }

      context 'if recipe is feautred' do
        before { recipe.update(day: 1)}
        it 'cannot be deleted' do
          req()
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'has errors' do
          req()
          expect(json['errors']).to have_key('day')
        end
        it 'does not change Recipe' do
          expect {req()}.not_to change(Recipe, :count)
        end
      end

      context 'if recipe isnt featured' do
        it 'returns :ok' do
          req()
          expect(response).to have_http_status(:ok)
        end
        it 'is deleted' do
          recipe.inspect
          expect(Recipe.count).to be > 0
          expect {req()}.to change(Recipe, :count).by(-1)
        end
      end
    end
  end
end
