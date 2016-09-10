class Operator::MissionsController < Operator::ApplicationController

  def index
    securities = Security.limit(10)
    @securities_info = securities.map do |e|
      e.security_info
    end
  end

  # params:
  # company_id
  # type
  # operator
  def create
    p = Prospectus.where(company_id: params[:company_id]).first
    do_mission = DoMission.create(prospectus_id: p.id, operator: current_user.id, status: 1, expired_at: Time.now + 10.days)
    render json: retval_wrapper({id: do_mission.id.to_s}) and return
  end

  def show
    @do_mission = DoMission.where(id: params[:id]).first
    @prospectus = @do_mission.prospectus
    @company = @prospectus.company
    @security = @company.securities.where(_type: "NeeqSecurity").first
  end
end
