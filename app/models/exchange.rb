class Exchange
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :abbrev, type: String
  field :country_code, type: String

  has_many :securities
  has_many :prospectuses
end