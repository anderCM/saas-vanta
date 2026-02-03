# Policy for PurchaseOrder authorization
#
# Any user in the enterprise can manage purchase orders.
class PurchaseOrderPolicy < ApplicationPolicy
  # Everyone in the enterprise can view purchase orders
  def index?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Everyone in the enterprise can view a purchase order
  def show?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Everyone in the enterprise can create purchase orders
  def create?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Everyone in the enterprise can edit draft purchase orders
  def update?
    platform_super_admin? || belongs_to_enterprise?
  end

  # Only admins can delete purchase orders
  def destroy?
    platform_super_admin? || enterprise_super_admin?
  end

  # Status transitions - everyone can perform these
  def confirm?
    platform_super_admin? || belongs_to_enterprise?
  end

  def receive?
    platform_super_admin? || belongs_to_enterprise?
  end

  def cancel?
    platform_super_admin? || belongs_to_enterprise?
  end

  def prefill?
    platform_super_admin? || belongs_to_enterprise?
  end
end
