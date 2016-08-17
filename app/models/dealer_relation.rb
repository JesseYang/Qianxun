class DealerRelation
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: Integer
  field :start_date, type: Date
  field :end_date, type: Date

  belongs_to :security, class_name: "Security", inverse_of: :dealers
  belongs_to :dealer, class_name: "Company", inverse_of: :dealer_securities
end