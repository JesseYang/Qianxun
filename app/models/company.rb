class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :chn_name, type: String
  field :abbrev, type:String
  field :country_code, type: Integer
  field :website, type: String

  # for data import
  field :dongcai_code, type: String

  has_many :company_industries
  has_many :securities
  has_many :prospectuses
  has_many :annual_reports
  has_many :risks
  has_many :buisness_models
  has_many :competitions
  has_many :competitor_competitions, class_name: "competition", inverse_of: :competitor
  has_many :missions
end
