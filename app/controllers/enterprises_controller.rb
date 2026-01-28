class EnterprisesController < ApplicationController
  layout "auth", only: [ :index ]
  skip_enterprise_selection only: [ :index, :select ]

  def index
    @enterprises = Current.user.enterprises
  end

  def select
    if Current.user.enterprises.exists?(params[:id])
      session[:enterprise_id] = params[:id]
      Current.session.update!(enterprise_id: params[:id])
      redirect_to root_path
    else
      redirect_to enterprises_path, alert: "Invalid enterprise selected."
    end
  end
end
