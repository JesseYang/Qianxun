class Operator::MissionsController < Operator::ApplicationController

  def index
    securities = Security.limit(10)
    @securities_info = securities.map do |e|
      e.security_info
    end
  end
end
