class EnterprisePolicy < ApplicationPolicy
  def edit?
    platform_super_admin? || enterprise_super_admin?
  end

  def update?
    platform_super_admin? || enterprise_super_admin?
  end
end
