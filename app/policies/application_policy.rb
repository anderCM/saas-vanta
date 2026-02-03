# Base policy class for authorization
#
# All policies should inherit from this class and implement
# specific permission methods.
#
# @example Basic usage in a controller
#   authorize @product, :edit?
#
# @example Usage in views
#   <% if policy(@product).edit? %>
#     <%= link_to "Edit", edit_product_path(@product) %>
#   <% end %>
#
class ApplicationPolicy
  attr_reader :user, :enterprise, :record

  # Initialize the policy
  #
  # @param context [PolicyContext] the context containing user and enterprise
  # @param record [Object] the record to authorize against
  def initialize(context, record)
    @user = context.user
    @enterprise = context.enterprise
    @record = record
  end

  # Default permissions - all deny by default
  def index? = false
  def show? = false
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false

  private

  # Check if user is a platform super admin
  #
  # @return [Boolean]
  def platform_super_admin?
    user&.super_admin?
  end

  # Get the user's roles for the current enterprise
  #
  # @return [Array<String>] array of role slugs
  def enterprise_roles
    return [] unless user && enterprise

    @enterprise_roles ||= user.roles_for(enterprise)
  end

  # Check if user has any of the specified roles in the enterprise
  #
  # @param roles [Array<String, Symbol>] the roles to check
  #
  # @return [Boolean]
  def has_enterprise_role?(*roles)
    role_slugs = roles.map(&:to_s)
    (enterprise_roles & role_slugs).any?
  end

  # Check if user is an admin (super_admin or admin) in the enterprise
  #
  # @return [Boolean]
  def enterprise_admin?
    has_enterprise_role?(:super_admin, :admin)
  end

  # Check if user is a super_admin in the enterprise
  #
  # @return [Boolean]
  def enterprise_super_admin?
    has_enterprise_role?(:super_admin)
  end

  # Check if user belongs to the enterprise
  #
  # @return [Boolean]
  def belongs_to_enterprise?
    enterprise_roles.any?
  end

  # Check if user can manage resources (platform super_admin or enterprise admin)
  #
  # @return [Boolean]
  def can_manage?
    platform_super_admin? || enterprise_admin?
  end
end
