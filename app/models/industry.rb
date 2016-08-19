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
  field :desc, type: String

  has_many :company_industries
  has_many :children, class_name: "Industry", inverse_of: :parent
  belongs_to :parent, class_name: "Industry", inverse_of: :children

  def self.load_investment_categories
    cur_lev_1 = nil
    cur_lev_2 = nil
    cur_lev_3 = nil
    CSV.foreach("materials/categories_investment.csv") do |row|
      # 1. handle the first level
      if row[0].present?
        cur_lev_1 = Industry.create(standard: INVESTMENT, industry_code: row[0], industry_name: row[5], level: 1)
      end

      # 2. handle the second level
      if row[6].present?
        if cur_lev_1.nil?
          byebug
        end
        cur_lev_2 = cur_lev_1.children.create(standard: INVESTMENT, industry_code: row[6], industry_name: row[7], level: 2)
      end

      # 3. handle the third level
      if row[8].present?
        if cur_lev_2.nil?
          byebug
        end
        cur_lev_3 = cur_lev_2.children.create(standard: INVESTMENT, industry_code: row[8], industry_name: row[9], level: 3)
      end

      if cur_lev_3.nil?
        byebug
      end
      cur_lev_3.children.create(standard: INVESTMENT, industry_code: row[10], industry_name: row[11], desc: row[12..-1].join(','), level: 4)
    end
  end

  def self.load_zhengjianhui_categories
    cur_lev_1 = nil
    CSV.foreach("materials/categories_zhengjianhui.csv") do |row|
      # check whether all items are blank
      next if row.join("").strip.blank?
      if row[0].present?
        cur_lev_1 = Industry.create(standard: ZHENGJIANHUI, industry_name: row[2], desc: row[3].to_s, level: 1)
      elsif row[1].present?
        cur_lev_1.children.create(standard: ZHENGJIANHUI, industry_name: row[2], desc: row[3].to_s, level: 2)
      end
    end
  end

  def self.print(standard)
    Industry.where(standard: standard, level: 1).each { |e| e.print_ind("") }
  end

  def print_ind(indent)
    puts indent + self.industry_name
    self.children.each do |e|
      e.print_ind(indent + "  ")
    end
  end
end