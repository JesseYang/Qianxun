class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mobile, type: String
  field :password, type: String
  field :is_verified, type: Boolean
  field :verify_code, type: String
end