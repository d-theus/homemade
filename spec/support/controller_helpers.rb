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

shared_context 'an unauthorized request' do
  it 'returns 403' do
    req() if defined? req
    expect(response).to have_http_status(:forbidden)
  end
end

shared_context '401_response' do
  it 'returns 401' do
    req() if defined? req
    expect(response).to have_http_status(:unauthorized)
  end
end

shared_context 'an authorized request' do
  it 'does not return 403' do
    req() if defined? req
    expect(response).not_to have_http_status(:forbidden)
  end
end

shared_context 'unprocessable entity request' do
  it 'returns (422) unprocessable entity' do
    req() if defined? req
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'has alert' do
    req() if defined? req
    expect(flash.now[:alert]).not_to be_nil
  end
end

shared_examples_for 'successful request' do
  it 'succeeds' do
    req() if defined? req
    expect(response).to have_http_status(:ok).or have_http_status(:found)
  end
end
