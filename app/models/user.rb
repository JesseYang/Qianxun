class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: Integer
  field :mobile, type: String
  field :password, type: String
  field :is_verified, type: Boolean
  field :verify_code, type: String
  field :auth_key, type: String

  def self.create_user(user_type, mobile)
    # 1. check whether user exists?
    u = User.where(mobile: mobile).first
    if u.present? && u.is_verified
      return ErrCode::USER_EXIST
    elsif u.blank?
      u = User.create(_type: user_type, mobile: mobile)
    end

    # 2. generate random code and save
    code = "111111"
    u.update_attribute(:verify_code, code)

    # 3. send message
    
    # 4. return user id
    { uid: u.id.to_s }
  end

  def verify_client(password, code)
    if verify_code != code
      return ErrCode::WRONG_VERIFY_CODE
    end
    self.update_attributes(is_verified: true, password: Encryption.encrypt_password(password))
    nil
  end

  def self.find_by_auth_key(auth_key)
    User.where(auth_key: auth_key).first
  end

  def self.signin_client(mobile, password)
    # byebug
    user = Client.where(mobile: mobile).first
    return ErrCode::USER_NOT_EXIST if user.nil?
    return ErrCode::USER_NOT_VERIFIED if user.is_verified == false
    return ErrCode::WRONG_PASSWORD if Encryption.encrypt_password(password) != user.password
    auth_key = user.generate_auth_key
    user.update_attribute(:auth_key, auth_key)
    return { auth_key: auth_key }
  end

  def generate_auth_key
    info = "#{self.id.to_s},#{Time.now.to_i}"
    Encryption.encrypt_auth_key(info)
  end
end