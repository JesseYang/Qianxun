class LoadDongcai

  def self.load
    load_record = LoadData.where(source: LoadData::DONGCAI).first
    if load_record.nil?
      LoadData.create(source: LoadData::DONGCAI)
    end

    self.load_companies
    self.load_securities
    self.load_dealers
    self.load_dealer_relations
    self.load_company_industries
  end

  # read data from ORGA_BI_ORGBASEINFO(Dongcai), and save to ChnCompany
  def self.load_companies(number = -1)
    cur_record_num = Company.count
    offset = 0
    batch_size = 5000
    import_number = 0
    while true
      batch = OrgaBiOrgbaseinfo.limit(batch_size).offset(offset)
      if batch.count == 0
        break
      end
      batch_info = []
      batch.each do |e|
        # load or update this record
        info = { # update data from dongcai record to our record
            name: e.COMPANYNAME,
            chn_name: e.COMPANYNAME,
            # abbrev: c.abbrev.blank? ? e.COMPANYSNAME : "#{c.abbrev},#{e.COMPANYSNAME}",
            abbrev: e.COMPANYSNAME,
            country_code: "86",
            organization_form: e.ORGFORM.to_i,
            established_at: e.FOUNDDATE.nil? ? nil : Date.new(* e.FOUNDDATE.split('-').map { |ele| ele.to_i }),
            reg_capital: e.REGCAPITAL.to_f,
            legal_person: e.LEGREPRESENT,
            reg_code: e.BLNUMB, # YingYeZhiZhao No.
            business_scope: e.BUSINSCOPE,
            location_code: e.CITY,
            website: e.COMPWEB,
            _type: "ChnCompany"
          }
        if cur_record_num == 0
          batch_info << info
        else
          c = ChnCompany.where(dongcai_code: e.COMPANYCODE).first
          c = c.nil? ? ChnCompany.create(dongcai_code: e.COMPANYCODE) : c
          c.update_attributes(info)
        end
      end
      ChnCompany.collection.insert_many(batch_info) if cur_record_num == 0
      offset = offset + batch_size
      import_number = import_number + batch.count
      if number > 0 && import_number >= number
        break
      end
    end
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
    securities.each do |e|
      s = Security.where(dongcai_code: e.SECURITYCODE).first
      if s.nil?
        c = Company.where(dongcai_code: e.COMPANYCODE).first
        s = c.securities.create(type: "NeeqSecurity")
        s.exchange = exchange
        import_number = import_number + 1
      else
        update_number = update_number + 1
      end
      s.update_attributes(
        {
          name: e.SECURITYNAME,
          code: e.SECURITYCODE,
          list_date: e.LISTDATE,
          delist_date: e.ENDDATE
        }
      )
    end
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
        d._type = "ChnDealerCompany"
        d.update_attribute(_type: "ChnDealerCompany")
        d = ChnDealerCompany.where(id: d.id).first
        update_number = update_number + 1
      end
      d.update_attributes(
        {
          license_code: e.LICENSECODE,
          security_buisness: e.SECURITYBUS
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
end
