class Client < User
  field :nickname, type: String

  has_many :do_missions, class_name: "DoMission", inverse_of: :doer
end