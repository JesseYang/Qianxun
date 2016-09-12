class DoMission
  include Mongoid::Document
  include Mongoid::Timestamps

  DOING = 1

  field :expired_at, type: Date
  field :audited_at, type: Date
  # 1 for doing
  field :status, type: Integer

  belongs_to :prospectus
  belongs_to :annual_report
  # belongs_to :mission
  belongs_to :auditor, class_name: "Staff", inverse_of: :audited_missions
  belongs_to :operator, class_name: "Client", inverse_of: :do_missions

  def security_info
    security = self.prospectus.company.securities[0]
    info = security.security_info.merge({mission_id: self.id.to_s})
    info
  end
end