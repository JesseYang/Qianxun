class AnnualReport
  include Mongoid::Document
  include Mongoid::Timestamps
  field :year, type: Integer
  field :structure, type: Array
  field :published_at, type: Date
  field :filename, type: String

  belongs_to :company
  belongs_to :security

  has_many :text_materials
  has_many :risks
  has_many :buisness_models
end
