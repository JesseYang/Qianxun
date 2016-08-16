class TextMaterial
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :type, type: Integer
  field :content, type: String

  belongs_to :prospectus
  belongs_to :annual_report
end