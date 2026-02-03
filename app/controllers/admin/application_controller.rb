class Admin::ApplicationController < ApplicationController
  before_action :require_super_admin!

  private

  def require_super_admin!
    Rails.logger.info "Checking super admin permission. User: #{Current.user&.id}, Role: #{Current.user&.platform_role}, Status: #{Current.user&.status}"
    unless Current.user&.super_admin?
      redirect_to root_path, alert: "No tienes permisos para acceder a esta página."
    end
  end
end
