require 'rails_helper'

RSpec.describe InventoryItemsController, type: :controller do
  let(:json) { JSON.parse! response.body }
  describe 'index' do
    it_requires_authentication(:get, :index)

    context 'when authorized' do
      before { sign_in }
      it 'returns json' do
        get :index
        expect(response).to have_http_status(:success)
        expect { json }.not_to raise_error
      end
    end
  end

  describe 'show' do
    before do
      sign_in nil
      @ii = FactoryGirl.create(:inventory_item)
    end

    it 'succeed without authentication' do
      get :show, id: @ii.id
      expect(response).to have_http_status(:success)
      expect(json).to have_key("inventory_item")
    end
  end

  describe 'create' do
    let(:inventory_item) { FactoryGirl.attributes_for(:inventory_item) }
    let(:bad_inventory_item) { FactoryGirl.attributes_for(:inventory_item_with_no_name) }

    it_requires_authentication(:post, :create)

    context 'when authorized' do
      before { sign_in }

      context 'with valid item' do
        it 'creates an inventory item' do
          count = InventoryItem.count
          post :create, inventory_item: inventory_item
          expect(response).to have_http_status(:success)
          expect(InventoryItem.count).to eq(count + 1)
        end
      end

      context 'with invalid item' do
        let(:req) { post :create, inventory_item: bad_inventory_item  }
        it 'does not create an inventory item' do
          expect { req() }.not_to change(InventoryItem, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json).to have_key('errors')
          expect(json['errors']).to have_key('name')
        end
      end
    end
  end

  describe 'update' do
    it_requires_authentication(:put, :update, id: rand(256))

    context 'when authorized' do
      let!(:ii) { FactoryGirl.create(:inventory_item) }
      before { sign_in }

      context 'with valid item' do
        it 'updates an inventory item' do
          post :update, id: ii.id, inventory_item: { name: 'Changed' }
          expect(response).to have_http_status(:success)
          expect(InventoryItem.find(ii.id).name).to eq('Changed')
        end
      end

      context 'with invalid item' do
        before { post :update, id: ii.id, inventory_item: { name: '' } }
        it 'returns unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json).to have_key('errors')
          expect(json['errors']).to have_key('name')
        end

        it 'does not update an inventory item' do
          expect { put :update, id: ii.id, inventory_item: { name: '' } }.not_to change(InventoryItem, :last)
        end
      end
    end
  end

  describe 'destroy' do
    it_requires_authentication(:delete, :destroy, id: rand(256))

    context 'when authorized' do
      before { sign_in }
      context 'given existent item with no recipes associated' do
        before { FactoryGirl.create(:inventory_item) }
        let(:id) { InventoryItem.last.id }

        it 'returns 200' do
          delete :destroy, id: id
          expect(response).to have_http_status(:ok)
        end
        
        it 'reduces count of InventoryItem by 1' do
          expect { delete :destroy, id: id }.to change(InventoryItem, :count).by(-1)
        end
      end

      context 'given existent item with recipe associated' do
        let!(:recipe) { FactoryGirl.create(:recipe_with_inventory_items) }
        let(:req) { delete :destroy, id: recipe.inventory_items.first.id }

        it 'is not being deleted' do
          expect { req() }.not_to change(InventoryItem, :count)
        end

        it 'returns :bad_request' do
          req()
          expect(response).to have_http_status(:bad_request)
        end

        it 'describes error' do
          req()
          expect(json).to have_key('errors')
          expect(json['errors'].values.join).to match /.*зависимости.*/
        end
      end
    end
  end
end
