class Client::SessionsController < Client::ApplicationController
  layout "layouts/session"

  def signup
    retval = User.create_user("Client", params[:mobile])
    render json: retval_wrapper(retval)
  end

  def verify
    user = User.where(id: params[:id]).first
    retval = user.nil? ? ErrCode::USER_NOT_EXIST : user.verify_client(params[:password], params[:verify_code])
    render json: retval_wrapper(retval)
  end

  # show the index page
  def index
  end

  # signin
  def create
    retval = User.signin_client(params[:mobile], params[:password])
    if retval.class == Hash && retval[:auth_key].present?
      cookies[:auth_key] = {
        :value => retval[:auth_key],
        :expires => 24.months.from_now,
        :domain => :all
      }
    end
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
    redirect_to new_client_session_path
  end
end
