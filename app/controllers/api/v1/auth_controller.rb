class Api::V1::AuthController < ApiController
  # For Rails 5, note that protect_from_forgery is no longer prepended
  # to the before_action chain, so if you have set authenticate_user
  # before protect_from_forgery, your request will result
  # in "Can't verify CSRF token authenticity." To resolve this,
  # either change the order in which you call them, or use protect_from_forgery prepend: true.
  protect_from_forgery prepend: true
  before_action :authenticate_user!, only: :logout

  # POST /api/v1/login
  def login
    if params[:email] && params[:password]
      user = User.find_by_email(params[:email])
    end

    if user && user.valid_password?(params[:password])
      render json: {
        message: "Ok",
        auth_token: user.authentication_token,
        user_id: user.id}
    else
      render json: { message:  "Email or Password is wrong" }, status:  401
    end
  end

  # POST /api/v1/logout
  def logout
    # 登入時刷新 token，做為下次登入時比對用，而舊的 token 就失效了
    current_user.generate_authentication_token
    current_user.save!

    render json: { message:  "Ok" }
  end
end