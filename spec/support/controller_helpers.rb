module ControllerHelpers
  def sign_in(admin = double('admin'))
    if admin.nil?
      #allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, {:scope => :admin})
      allow(controller).to receive(:current_admin).and_return(nil)
    else
      #allow(request.env['warden']).to receive(:authenticate!).and_return(admin)
      allow(controller).to receive(:current_admin).and_return(admin)
    end
  end
end

def it_requires_authentication(verb, action, parameters = {})
  context 'when unauthorized' do
    before { sign_in nil }
    it 'returns 403' do
      self.send(verb, action, parameters)
      expect(response).to have_http_status(:forbidden)
    end
  end
end

def it_handles_nonexistent(verb, action, parameters = {})
  context 'when nonexistent id' do
    it 'returns 404' do
      expect { self.send(verb, action, parameters) }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
