class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :set_current_user
  
  rescue_from JWT::DecodeError, with: :unauthorized
  rescue_from JWT::ExpiredSignature, with: :unauthorized
  
  private
  
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last ||
            cookies[:auth_token]
    
    if token
      begin
        decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
        @current_user = User.find(decoded[0]['user_id'])
      rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
        unauthorized
      end
    else
      redirect_to login_path unless request.path == login_path || request.path == register_path
    end
  end
  
  def set_current_user
    # Current user is already set in authenticate_user!
  end
  
  def current_user
    @current_user
  end
  helper_method :current_user
  
  def unauthorized
    respond_to do |format|
      format.html { redirect_to login_path, alert: 'Session expired. Please login again.' }
      format.json { render json: { error: 'Unauthorized' }, status: 401 }
    end
  end
  
  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end
end