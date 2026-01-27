# Policy for Provider authorization
#
# Defines who can view, create, edit, and delete providers.
class ProviderPolicy < ApplicationPolicy
  # Everyone in the enterprise can view providers list
  def index?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Everyone in the enterprise can view a provider
  def show?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Only admins can create providers
  def create?
    can_manage?
  end

  # Only admins can edit providers
  def update?
    can_manage?
  end

  # Only super_admins can delete providers
  def destroy?
    platform_super_admin? || enterprise_super_admin?
  end
end
