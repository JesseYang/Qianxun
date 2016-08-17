class NeeqSecurity < Security
  field :layer, type: Integer

  has_many :dealers, class_name: "DealerRelation", inverse_of: :security
end