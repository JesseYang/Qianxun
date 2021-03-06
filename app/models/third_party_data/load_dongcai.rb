class LoadDongcai

  def self.load
    @load_record = LoadData.where(source: LoadData::DONGCAI).first

    self.load_companies
    self.load_securities
    self.load_dealers
    self.load_dealer_relations
    self.load_company_industries

    @load_record = @load_record || LoadData.create(source: LoadData::DONGCAI)
    @load_record.touch
  end

  # read data from ORGA_BI_ORGBASEINFO(Dongcai), and save to ChnCompany
  def self.load_companies(number = -1)
    offset = 0
    import_number = 0
    update_number = 0
    batch = @load_record.nil? ? OrgaBiOrgbaseinfo.all : OrgaBiOrgbaseinfo.where(UPDATEDATE: @load_record.updated_at..Date.today)
    batch_info = []
    batch.each do |e|
      # load or update this record
      c = ChnCompany.where(dongcai_code: e.COMPANYCODE).first
      date = nil
      begin
        date = Date.new(* e.FOUNDDATE.split('-').map { |ele| ele.to_i })
      rescue
      end
      info = { # update data from dongcai record to our record
          dongcai_code: e.COMPANYCODE,
          name: e.COMPANYNAME,
          chn_name: e.COMPANYNAME,
          abbrev: c.try(:abbrev).blank? ? e.COMPANYSNAME : "#{c.abbrev},#{e.COMPANYSNAME}",
          country_code: "86",
          organization_form: e.ORGFORM.to_i,
          # established_at: e.FOUNDDATE.nil? ? nil : Date.new(* e.FOUNDDATE.split('-').map { |ele| ele.to_i }),
          established_at: date,
          reg_capital: e.REGCAPITAL.to_f,
          legal_person: e.LEGREPRESENT,
          reg_code: e.BLNUMB, # YingYeZhiZhao No.
          business_scope: e.BUSINSCOPE,
          location_code: e.CITY,
          website: e.COMPWEB,
          _type: "ChnCompany"
        }
      if c.nil?
        info[:created_at] = Time.now
        info[:updated_at] = Time.now
        batch_info << info
        import_number = import_number + 1
      else
        c.update_attributes(info)
        update_number = update_number + 1
      end
    end
    ChnCompany.collection.insert_many(batch_info)
    puts "import #{import_number}, update #{update_number}"
    true
  end

  def self.load_securities
    exchange = Exchange.where(name: "全国中小企业股份转让系统").first
    if exchange.nil?
      puts "error, cannot find the correct exchange !!"
      return false
    end
    import_number = 0
    update_number = 0
    securities = CdsySecucode.where(TRADEMARKET: "新三板")
    batch_info = []
    securities.each do |e|
      s = Security.where(dongcai_code: e.SECURITYCODE).first
      info = {
        name: e.SECURITYNAME,
        code: e.SECURITYCODE,
        list_date: e.LISTDATE,
        delist_date: e.ENDDATE,
        _type: "NeeqSecurity",
        exchange_id: exchange.id,
      }
      if s.nil?
        c = Company.where(dongcai_code: e.COMPANYCODE).first
        puts e.COMPANYCODE
        # s = c.securities.create(_type: "NeeqSecurity")
        info[:company_id] = c.id
        info[:created_at] = Time.now
        info[:updated_at] = Time.now
        batch_info << info
        # s.exchange = exchange
        import_number = import_number + 1
      else
        update_number = update_number + 1
        s.update_attributes(info)
      end
    end
    NeeqSecurity.collection.insert_many(batch_info)
    puts "import #{import_number}, update #{update_number}"
    true
  end

  def self.load_dealers
    import_number = 0
    update_number = 0
    dealers = SemkOcComppro.all
    dealers.each do |e|
      d = Company.where(dongcai_code: e.COMPANYCODE).first
      if d.nil?
        d = ChnDealerCompany.create(dongcai_code: e.COMPANYCODE).first
        import_number = import_number + 1
      else
        d.update_attribute(:_type, "ChnDealerCompany")
        d = ChnDealerCompany.where(id: d.id).first
        update_number = update_number + 1
      end
      d.update_attributes(
        {
          license_code: e.LICENSECODE,
          security_business: e.SECURITYBUS
        }
      )
    end
    puts "import #{import_number}, update #{update_number}"
    true
  end

  def self.load_dealer_relations
    import_number = 0
    update_number = 0
    dealer_relations = OrgaBiOrgparty.where(PARTYTYPE: ["06", "07", "08"])
    dealer_relations.each do |e|
      c = Company.where(dongcai_code: e.COMPANYCODE).first
      d = Company.where(dongcai_code: e.PARTYCODE).first
      s = c.securities.where(_type: "NeeqSecurity").first if c.present?
      if c.nil? || d.nil? || s.nil?
        next
      end
      dr = DealerRelation.where(security_id: s.id, dealer_id: d.id).first
      if dr.nil?
        dr = DealerRelation.create(security_id: s.id, dealer_id: d.id)
        import_number = import_number + 1
      else
        update_number = update_number + 1
      end
      dr.update_attributes(
        {
          type: e.PARTYTYPE.to_i,
          start_date: e.NEWSTARTDATE.nil? ? nil : Date.new(e.NEWSTARTDATE.year, e.NEWSTARTDATE.month, e.NEWSTARTDATE.day),
          end_date: e.NEWENDDATE.nil? ? nil : Date.new(e.NEWENDDATE.year, e.NEWENDDATE.month, e.NEWENDDATE.day)
        }
      )
    end
  end

  def self.load_company_industries
    zjh_data = LicoImInchg.where(INDTYPE: LicoImInchg::ZHENGJIANHUI, ISNEW: "1")
    zjh_data.each do |e|
      industry_name = e.INDSORT
      c = Company.where(dongcai_code: e.COMPANYCODE).first
      i = Industry.where(industry_name: e.INDSORT, standard: Industry::ZHENGJIANHUI).first
      next if c.nil? || i.nil?
      ci = CompanyIndustry.create(company_id: c.id, industry_id: i.id)
    end

    inv_data = LicoImInchg.where(INDTYPE: "014", ISNEW: "1")
    inv_data.each do |e|
      industry_name = e.INDSORT
      c = Company.where(dongcai_code: e.COMPANYCODE).first
      i = Industry.where(industry_name: e.INDSORT, standard: Industry::INVESTMENT).first
      next if c.nil? || i.nil?
      ci = CompanyIndustry.create(company_id: c.id, industry_id: i.id)
    end
  end

  def self.load_reports

=begin
    browser = Watir::Browser.new
    browser.goto 'http://www.neeq.com.cn/disclosure/announcement.html'
    browser.text_field(id: 'startDate').set '2012-01-01'
    page = Nokogiri::HTML.parse(browser.html)
          browser.text_field(id: 'keyword').set '公开转让'
          browser.link(:text => "查询").click
=end
    
    exchange = Exchange.where(name: "全国中小企业股份转让系统").first
    if exchange.nil?
      puts "error, cannot find the correct exchange !!"
      return false
    end
    Security.all.each do |s|
      company_code = s.company.dongcai_code
      # puts company_code
      c = s.company
      next if c.prospectuses.length > 0
      infos = InfoAnRelcodesemk.where(COMPAYCODE: company_code)
      infos.each do |info|
        info_code = info.INFOCODE
        v = InfoAnRelcolumnsemk.where(INFOCODE: info_code).first
        next if v.nil?
        # puts v.COLUMNCODE
        ele = nil
        is_prospectus = nil
        if v.COLUMNNAME == "公开转让说明书"
          data = InfoAnBasinfosemk.where(INFOCODE: info_code).first
          name = data.try(:NOTICETITLE)
          next if name.blank?
          ele = Prospectus.create(name: name, exchange_id: exchange.id, company_id: s.company.id, published_at: data.NOTICEDATE)
          is_prospectus = true
        elsif v.COLUMNNAME == "年度报告全文"
          data = InfoAnBasinfosemk.where(INFOCODE: info_code).first
          name = data.try(:NOTICETITLE)
          next if name.blank?
          ele = AnnualReport.create(name: name, security_id: s.id, company_id: s.company.id, published_at: data.NOTICEDATE)
          is_prospectus = false
        else
          next
        end
        download_info = InfoAnBasinfosemk.where(INFOCODE: info_code).first
        next if download_info.nil?
        download_url = download_info.SOURCEURL
        ele.update_attribute(:dongcai_url, download_url)
        if download_url.include?("file.neeq.com.cn")
          download_url.gsub!("file", "www")
        end
=begin
        begin
          uuid = SecureRandom.uuid
          file_path = is_prospectus ? "public/downloads/prospectus/#{uuid}.pdf" : "public/downloads/annual_reports/#{uuid}.pdf"
          File.open(file_path, "wb") do |saved_file|
            # the following "open" is provided by open-uri
            open(download_url, "rb") do |read_file|
              saved_file.write(read_file.read)
            end
          end
          ele.update_attribute(:file_path, file_path)
        rescue => err
          File.delete(file_path)
        end
=end
      end
    end
  end
end

