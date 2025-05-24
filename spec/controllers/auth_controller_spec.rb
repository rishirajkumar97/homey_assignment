require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  describe 'GET #login' do
    it 'renders login page' do
      get :login
      expect(response).to be_successful
      expect(response).to render_template(:login)
    end
  end

  describe 'GET #register' do
    it 'renders register page with new user' do
      get :register
      expect(response).to be_successful
      expect(response).to render_template(:register)
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #create_session' do
    let(:user) { create(:user, user_name: 'testuser', password: 'password') }

    context 'with valid credentials' do
      it 'logs in user and redirects to projects' do
        post :create_session, params: { user_name: 'testuser', password: 'password' }
        
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid credentials' do
      it 'renders login with error' do
        post :create_session, params: { user_name: 'testuser', password: 'wrong' }
        
        expect(response).to render_template(:login)
        expect(flash[:alert]).to eq('Invalid username or password')
        expect(cookies[:auth_token]).to be_nil
      end
    end

    context 'with non-existent user' do
      it 'renders login with error' do
        post :create_session, params: { user_name: 'nonexistent', password: 'password' }
        
        expect(response).to render_template(:login)
        expect(flash[:alert]).to eq('Invalid username or password')
      end
    end
  end

  describe 'POST #create_user' do
    let(:valid_params) do
      {
        user: {
          user_name: 'newuser',
          email: 'new@example.com',
          full_name: 'New User',
          password: 'password',
          password_confirmation: 'password',
          role: 'member'
        }
      }
    end

    context 'with valid params' do
      it 'creates user and redirects to projects' do
        expect {
          post :create_user, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(projects_path)
        expect(flash[:notice]).to eq('Account created successfully!')
        expect(cookies[:auth_token]).to be_present
      end
    end

    context 'with invalid params' do
      it 'renders register with errors' do
        invalid_params = valid_params.dup
        invalid_params[:user][:email] = 'invalid-email'

        post :create_user, params: invalid_params
        
        expect(response).to render_template(:register)
        expect(assigns(:user).errors).to be_present
      end
    end
  end

  describe 'DELETE #logout' do
    let(:user) { create(:user) }

    before { login_user(user) }

    it 'logs out user and redirects to login' do
      delete :logout
      
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq('Successfully logged out!')
      expect(cookies[:auth_token]).to be_nil
    end
  end
end