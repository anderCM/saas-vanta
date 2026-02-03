# Policy for Product authorization
#
# Defines who can view, create, edit, and delete products.
class ProductPolicy < ApplicationPolicy
  # Everyone in the enterprise can view products list
  def index?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Everyone in the enterprise can view a product
  def show?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Only admins can create products
  def create?
    can_manage?
  end

  # Only admins can edit products
  def update?
    can_manage?
  end

  # Only super_admins can delete products
  def destroy?
    platform_super_admin? || enterprise_super_admin?
  end
end
