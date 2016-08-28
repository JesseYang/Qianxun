class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: Integer    # 0 for prospectus, 1 for annual repots
  field :security_code, type: String
  field :href, type: String
  field :name, type: String
  field :date, type: Date

  def self.download_reports
    browser = Watir::Browser.new
    browser.goto 'http://www.neeq.com.cn/disclosure/announcement.html'
    browser.select_list(:id, "companyTypeId").select_value("4")
    browser.text_field(id: 'startDate').set '2012-01-01'
    browser.text_field(id: 'keyword').set '公开转让'
    browser.link(:text => "查询").click
    page = Nokogiri::HTML.parse(browser.html)

    page_num = 0

    while (true)
      page_num = page_num + 1
      table = page.css("#companyTable")
      records = table.css("tr")
      records.each do |tr|
        security_code = tr.css("td")[0].text
        name = tr.css("td")[1].text
        href = tr.css("td")[1].css("a")[0]['href']
        date_ary = tr.css("td")[2].text.split('-')
        year = date_ary[0].to_i
        month = date_ary[1].to_i
        day = date_ary[2].to_i
        date = Date.new(year, month, day)
        Report.create(security_code: security_code, name: name, href: href, date: date, type: 0)
      end

      puts "************** PAGE #{page_num} ****************"

      begin
        browser.link(:class => "next").click
      rescue
        byebug
      end

      sleep(1)
      page = Nokogiri::HTML.parse(browser.html)
    end
  end
end
