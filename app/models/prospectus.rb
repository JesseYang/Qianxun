require 'open-uri'
class Prospectus
  include Mongoid::Document
  include Mongoid::Timestamps
  field :structure, type: Array, default: [ ]
  field :published_at, type: Date
  field :name, type: String
  field :file_path, type: String
  field :dongcai_url, type: String

  belongs_to :company
  belongs_to :exchange

  has_many :text_materials
  has_many :risks
  has_many :buisness_models
  has_many :competitions
  has_many :do_missions

  def self.years_for_select
    hash = { }
    (1990..2016).to_a.each do |y|
      hash[y.to_s] = y.to_s
    end
    hash
  end

  def self.risks_for_select
    hash = {
      "请选择特定风险类型": -1,
      "上游供应商资金风险": 1,
      "下游客户关联风险": 2,
      "资金链断裂风险": 4
    }
    hash
  end

  def self.business_modes_for_select
    hash = {
      "请选择商业模式": -1,
      "商业模式": 1,
      "盈利模式": 2,
      "销售模式": 4,
      "采购模式": 8,
      "采购模式": 16,
      "生产模式": 32
    }
    hash
  end

  def self.download_file
    browser = Watir::Browser.new
    browser.goto 'http://www.neeq.com.cn/disclosure/announcement.html'
    Prospectus.all.each do |p|
      next if p.file_path.present?

      keyword = p.name
      browser.text_field(id: 'startDate').set '2001-01-01'
      browser.text_field(id: 'keyword').set keyword
      browser.link(:text => "查询").click
      sleep(1)
      page = Nokogiri::HTML.parse(browser.html)

      table = page.css("#companyTable")
      records = table.css("tr")
      if records.length == 0
        if keyword.include?(":")
          new_keyword = keyword.gsub(':', '：')
        elsif keyword.include?("：")
          new_keyword = keyword.gsub('：', ':')
        end
        if new_keyword != keyword
          keyword = new_keyword
          browser.text_field(id: 'keyword').set keyword
          browser.link(:text => "查询").click
          sleep(1)
          page = Nokogiri::HTML.parse(browser.html)

          table = page.css("#companyTable")
          records = table.css("tr")
        end
      end
      records.each do |tr|
        security_code = tr.css("td")[0].text
        name = tr.css("td")[1].text
        href = tr.css("td")[1].css("a")[0]['href']
        date_ary = tr.css("td")[2].text.split('-')
        year = date_ary[0].to_i
        month = date_ary[1].to_i
        day = date_ary[2].to_i
        date = Date.new(year, month, day)

        if name == keyword
          # download file
          uuid = SecureRandom.uuid
          File.open("public/downloads/prospectus/#{uuid}.pdf", "wb") do |saved_file|
            # the following "open" is provided by open-uri
            open("http://www.neeq.com.cn/#{href}", "rb") do |read_file|
              saved_file.write(read_file.read)
            end
          end
          p.update_attributes(
            {
              file_path: "/downloads/prospectus/#{uuid}.pdf",
              published_at: date
            }
          )
          break
        end
      end

    end
  end

  def get(type)
    ele = self.structure.select { |e| e["key"] == type }
    ele.present? ? ele[0]["content"] : nil
  end

  def get_base_year(type)
    content = self.get("main_#{type}s")
    (content.blank? ? Time.now.year : content.keys.map { |e| e.to_i } .max) .to_s
  end
end
