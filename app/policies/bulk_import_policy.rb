# Policy for BulkImport authorization
#
# Defines who can view, create, and manage bulk imports.
class BulkImportPolicy < ApplicationPolicy
  # Only admins can view import history
  def index?
    can_manage?
  end

  # Only admins can view import details
  def show?
    can_manage?
  end

  # Only admins can create imports
  def create?
    can_manage?
  end

  # Only admins can download templates
  def template?
    can_manage?
  end
end
