class Industry
  include Mongoid::Document
  include Mongoid::Timestamps
  field :standard, type: Integer
  field :industry_code, type: String
  field :industry_name, type: String
  field :level, type: String

  has_many :company_industries
  has_many :children, class_name: "Industry", inverse_of: :parent
  belongs_to :parent, class_name: "Industry", inverse_if: :children
end