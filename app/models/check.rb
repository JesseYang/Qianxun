class Check
  include Mongoid::Document
  include Mongoid::Timestamps
  field :data_type, type: Integer
  field :data_id, type: String
  field :result, type: Boolean

  belongs_to :checker, class_name: "Staff", inverse_of: :checks
end