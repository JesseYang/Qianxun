class Operator::MissionsksController < Operator::ApplicationController

  def index
    @misions = Company.limit(10)
  end

end
