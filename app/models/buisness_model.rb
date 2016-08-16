class BuisnessModel
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: Integer
  field :content, type: String
  field :change_flag, type:Boolean

  belongs_to :prospectus
  belongs_to :annual_report
  belongs_to :company
end