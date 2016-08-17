class LoadDongcai

  def self.load
    load_record = LoadData.where(source: LoadData::DONGCAI).first
    if load_record.nil?
      LoadData.create(source: LoadData::DONGCAI)
    end

    self.load_companies
  end

  # read data from ORGA_BI_ORGBASEINFO(Dongcai), and save to ChnCompany
  def self.load_companies(number)
    offset = 0
    batch_size = 5
    import_number = 0
    while true
      batch = OrgaBiOrgbaseinfo.limit(batch_size).offset(offset)
      if batch.count == 0
        break
      end
      batch.each do |e|
        # load or update this record
        c = ChnCompany.where(dongcai_code: e.COMPANYCODE).first
        c = c.nil? ? ChnCompany.create(dongcai_code: e.COMPANYCODE) : c
        c.update_attributes(
          { # update data from dongcai record to our record
            name: e.COMPANYNAME,
            chn_name: e.COMPANYNAME,
            abbrev: c.abbrev.blank? ? e.COMPANYSNAME : "#{c.abbrev},#{e.COMPANYSNAME}",
            country_code: "86",
            organization_form: e.ORGFORM,
            established_at: e.FOUNDDATE.nil? ? nil : Date.new(* e.FOUNDDATE.split('-').map { |ele| ele.to_i }),
            reg_capital: e.REGCAPITAL,
            legal_person: e.LEGREPRESENT,
            reg_code: e.BLNUMB, # YingYeZhiZhao No.
            business_scope: e.BUSINSCOPE,
            location_code: e.CITY,
            website: e.COMPWEB
          }
        )
      end
      offset = offset + batch_size
      import_number = import_number + batch.count
      if number > 0 && import_number >= number
        break
      end
    end
  end

  def self.load_securities(number)
  end

end
