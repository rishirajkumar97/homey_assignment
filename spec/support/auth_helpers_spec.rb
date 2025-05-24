module AuthHelpers
  def login_user(user = nil)
    user ||= create(:user)
    
    # For controller tests
    if respond_to?(:session)
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
      cookies[:auth_token] = token
    end
    
    # For request tests
    if respond_to?(:request)
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
      request.cookies[:auth_token] = token if request
    end
    
    user
  end

  def logout_user
    cookies.delete(:auth_token) if respond_to?(:cookies)
    request.cookies.delete(:auth_token) if respond_to?(:request) && request
  end
end