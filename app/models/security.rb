class Security
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :code, type: String
  field :list_date, type: Date
  field :delist_date, type: Date

  belongs_to :company
  belongs_to :exchange
  has_many :annual_reports
end