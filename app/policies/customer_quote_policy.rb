class CustomerQuotePolicy < ApplicationPolicy
  def index?
    platform_super_admin? || belongs_to_enterprise?
  end

  def show?
    platform_super_admin? || belongs_to_enterprise?
  end

  def create?
    platform_super_admin? || belongs_to_enterprise?
  end

  def update?
    platform_super_admin? || belongs_to_enterprise?
  end

  def destroy?
    platform_super_admin? || enterprise_super_admin?
  end

  def accept?
    platform_super_admin? || belongs_to_enterprise?
  end

  def reject?
    platform_super_admin? || belongs_to_enterprise?
  end

  def expire?
    platform_super_admin? || belongs_to_enterprise?
  end
end
