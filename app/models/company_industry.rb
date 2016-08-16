class CompanyIndustry
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :industry
  belongs_to :company
end