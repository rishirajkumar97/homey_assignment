class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login, :register, :create_session, :create_user]
  
  def login
    render layout: 'auth'
  end
  
  def register
    @user = User.new
    render layout: 'auth'
  end
  
  def create_session
    user = User.find_by(user_name: params[:user_name])
    
    if user&.authenticate(params[:password])
      token = generate_jwt_token(user)
      cookies[:auth_token] = {
        value: token,
        expires: 24.hours.from_now,
        httponly: true
      }
      
      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'Successfully logged in!' }
        format.json { render json: { token: token, user: user.as_json(only: [:id, :user_name, :full_name, :email, :role]) } }
      end
    else
      respond_to do |format|
        format.html { 
          flash.now[:alert] = 'Invalid username or password'
          render :login, layout: 'auth'
        }
        format.json { render json: { error: 'Invalid credentials' }, status: 401 }
      end
    end
  end
  
  def create_user
    @user = User.new(user_params)
    
    if @user.save
      token = generate_jwt_token(@user)
      cookies[:auth_token] = {
        value: token,
        expires: 24.hours.from_now,
        httponly: true
      }
      
      respond_to do |format|
        format.html { redirect_to projects_path, notice: 'Account created successfully!' }
        format.json { render json: { token: token, user: @user.as_json(only: [:id, :user_name, :full_name, :email, :role]) } }
      end
    else
      respond_to do |format|
        format.html { render :register, layout: 'auth' }
        format.json { render json: { errors: @user.errors }, status: 422 }
      end
    end
  end
  
  def logout
    cookies.delete(:auth_token)
    redirect_to login_path, notice: 'Successfully logged out!'
  end
  
  private
  
  def user_params
    params.require(:user).permit(:user_name, :password, :password_confirmation, :full_name, :email, :role)
  end
end