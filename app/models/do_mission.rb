class DoMission
  include Mongoid::Document
  include Mongoid::Timestamps
  field :expired_at, type: Date
  field :audited_at, type: Date
  field :status, type: Integer

  belongs_to :mission
  belongs_to :auditor, class_name: "Staff", inverse_of: :audited_missions
  belongs_to :doer, class_name: "Client", inverse_of: :do_missions
end