require 'csv'

class Industry
  include Mongoid::Document
  include Mongoid::Timestamps

  INVESTMENT = 14
  ZHENGJIANHUI = 8

  field :standard, type: Integer
  field :industry_code, type: String
  field :industry_name, type: String
  field :level, type: Integer

  has_many :company_industries
  has_many :children, class_name: "Industry", inverse_of: :parent
  belongs_to :parent, class_name: "Industry", inverse_of: :children

  def self.load_categories
    current_level = 1
    current_level_1 = nil
    current_level_2 = nil
    current_level_3 = nil
    CSV.foreach("materials/categories_investment.csv") do |row|
      puts row.join(" | ")
      break

      code = -1
      if row[0].present?
        this_level = 1
        code = row[0]
      elsif row[6].present?
        this_level = 2
        code = row[6]
      elsif row[8].present?
        this_level = 3
        code = row[8]
      elsif row[10].present?
        this_level = 4
        code = row[10]
      else
        next
      end
      Industry.create(standard: INVESTMENT, industry_code: code, industry_name)
    end
  end
end