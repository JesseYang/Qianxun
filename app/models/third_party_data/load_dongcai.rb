class LoadDongcai

  def self.load
    load_record = LoadData.where(source: LoadData::DONGCAI).first
    if load_record.nil?
      LoadData.create(source: LoadData::DONGCAI)
    end

    self.load_companies
  end

  def self.load_companies
    offset = 0
    batch_size = 5
    while true
      batch = OrgaBiOrgbaseinfo.limit(batch_size).offset(offset)
      if batch.count== 0
        break
      end
      batch.each do |e|
        # load or update this record
        c = ChnCompany.where(dongcai_code: e.COMPANYCODE).first
        c = c.nil? ? ChnCompany.create(dongcai_code: e.COMPANYCODE)
        c.update_attributes(
          { # update data from dongcai record to our record
          }
        )
      end
      offset = offset + batch_size
    end
  end
end
