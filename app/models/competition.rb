class Competition
  include Mongoid::Document
  include Mongoid::Timestamps
  field :competitor_abbrev, type: String
  field :competitor_description, type: String
  field :description, type:String

  belongs_to :prospectus
  belongs_to :company
  belonsg_to :competitor, class_name: "Company", inverse_of: "competitor_competitions"
end