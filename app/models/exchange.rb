class Exchange
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :abbrev, type: String
  field :country_code, type: String

  has_many :securities
  has_many :prospectuses

  def self.init
    if self.where(name: "全国中小企业股份转让系统").blank?
      self.create(name: "全国中小企业股份转让系统", abbrev: "新三板", country_code: "86")
    end
  end
end
