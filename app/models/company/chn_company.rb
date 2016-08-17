class ChnCompany < Company
  field :organization_form, type: Integer
  field :established_at, type: Date
  field :operating_period, type: Date
  field :reg_capital, type: Float
  field :paid_capital, type: Float
  field :legal_person, type: String
  field :reg_code, type: String
  field :social_credit_code, type: String
  field :business_scope, type: String
  field :location_code, type: String
end