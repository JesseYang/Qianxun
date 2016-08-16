class Risk
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :content, type: String
  field :risk_type, type: Integer
  field :change_type, type: Integer


  belongs_to :prospectus
  belongs_to :annual_report
  belongs_to :company
end