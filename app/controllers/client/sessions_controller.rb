class Client::SessionsController < Client::ApplicationController
  layout "layouts/session"

  def new_registrate
    
  end

  # show the index page
  def index
  end

  # signin
  def create
    retval = User.signin_staff(params[:mobile], params[:password])
    if retval.class == Hash && retval[:auth_key].present?
      cookies[:auth_key] = {
        :value => retval[:auth_key],
        :expires => 24.months.from_now,
        :domain => :all
      }
    end
    render json: retval_wrapper(retval)
  end

  # verify code
  def verify
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_staff(params[:name], params[:center], params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  # create new staff user, params include mobile, return verify code
  def signup
    retval = User.create_user(User::STAFF, params[:mobile])
    render json: retval_wrapper(retval)
  end

  def forget_password
    user = User.where(mobile: params[:mobile]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.forget_password
    render json: retval_wrapper(retval)
  end

  def reset_password
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.reset_password(params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  def signout
    cookies.delete(:auth_key, :domain => :all)
    redirect_to staff_sessions_path
  end
end
