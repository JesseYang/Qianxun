class Operator::MissionsController < Operator::ApplicationController

  def index
    if params[:type] == "mine"
      missions = current_user.do_missions
      @securities = auto_paginate(missions)
      @securities[:data] = @securities[:data].map do |e|
        e.security_info
      end
    else
      securities = Security.all
      @securities = auto_paginate(securities)
      @securities[:data] = @securities[:data].map do |e|
        e.security_info
      end
    end
  end

  # params:
  # company_id
  # type
  # operator
  def create
    p = Prospectus.where(company_id: params[:company_id]).first
    do_mission = DoMission.create(prospectus_id: p.id, operator_id: current_user.id, status: 1, expired_at: Time.now + 10.days)
    render json: retval_wrapper({id: do_mission.id.to_s}) and return
  end

  def show
    @do_mission = DoMission.where(id: params[:id]).first
    @prospectus = @do_mission.prospectus
    @company = @prospectus.company
    @security = @company.securities.where(_type: "NeeqSecurity").first
  end

  def update
    @do_mission = DoMission.where(id: params[:id]).first
    @prospectus = @do_mission.prospectus
    @prospectus.structure = params[:prospectus].map { |k, v| { key: k, content: v } }
    @prospectus.save
    render json: retval_wrapper(nil) and return
  end
end
