# Policy for User authorization
#
# Access rules:
# - Enterprise Admin: can only view users (index, show)
# - Enterprise Super Admin: can create, update, toggle status for their enterprise
# - Platform Super Admin: full access across all enterprises
# - No one can delete users, only deactivate them
#
class UserPolicy < ApplicationPolicy
  # Admin and Super Admin can view users list
  def index?
    platform_super_admin? || enterprise_admin?
  end

  # Admin and Super Admin can view user details
  def show?
    platform_super_admin? || enterprise_admin?
  end

  # Platform Super Admin or Enterprise Super Admin can create users
  def create?
    platform_super_admin? || enterprise_super_admin?
  end

  # Platform Super Admin or Enterprise Super Admin can update users
  def update?
    platform_super_admin? || enterprise_super_admin?
  end

  # Platform Super Admin or Enterprise Super Admin can toggle user status
  def toggle_status?
    platform_super_admin? || enterprise_super_admin?
  end

  # No one can destroy users - they should be deactivated instead
  def destroy?
    false
  end
end
