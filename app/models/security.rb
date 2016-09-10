class Security
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :code, type: String
  field :list_date, type: Date
  field :delist_date, type: Date

  belongs_to :company
  belongs_to :exchange
  has_many :annual_reports

  def security_info
    {
      id: self.id.to_s,
      code: self.code,
      list_date: self.list_date.strftime("%Y-%m-%d"),
      name: self.name,
      company_id: self.company_id.to_s,
      industry: self.company.company_industries[0].industry.industry_name
    }
  end
end