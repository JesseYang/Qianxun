class Staff < User
  field :name, type: String

  has_many :audited_missions, class_name: "DoMission", inverse_of: :auditor
  has_many :checks, class_name: "Check", inverse_of: :checker
end