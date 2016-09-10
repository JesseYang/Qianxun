class Mission
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: Integer
  field :reward, type: Integer

  # belongs_to :company
  # belongs_to :do_missions

  def self.generate_missions
  	
  end
end