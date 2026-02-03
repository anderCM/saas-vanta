# Policy for Customer authorization
#
# Defines who can view, create, edit, and delete customers.
class CustomerPolicy < ApplicationPolicy
  # Everyone in the enterprise can view customers list
  def index?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Everyone in the enterprise can view a customer
  def show?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Only admins can create customers
  def create?
    can_manage?
  end

  # Only admins can edit customers
  def update?
    can_manage?
  end

  # Only super_admins can delete customers
  def destroy?
    platform_super_admin? || enterprise_super_admin?
  end
end
