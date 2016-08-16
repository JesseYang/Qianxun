class LoadData
  include Mongoid::Document
  include Mongoid::Timestamps

  DONGCAI = 1

  field :source, type: Integer
  field :last_loaded_at, type: Time

end
