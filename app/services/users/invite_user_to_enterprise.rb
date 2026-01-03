class Users::InviteUserToEnterprise < BaseService
  REQUIRED_INPUTS = %w[enterprise user_email first_name first_last_name second_last_name role_slug].freeze

  def initialize(enterprise:, user_email:, first_name:, first_last_name:, second_last_name:, role_slug:, **kwargs)
    super()
    @enterprise = enterprise
    @user_email = user_email
    @first_name = first_name
    @first_last_name = first_last_name
    @second_last_name = second_last_name
    @role_slug = role_slug
    @kwargs = kwargs
  end

  def call
    received_inputs = {
      enterprise: @enterprise,
      user_email: @user_email,
      first_name: @first_name,
      first_last_name: @first_last_name,
      second_last_name: @second_last_name,
      role_slug: @role_slug
    }

    unless valid_required_inputs?(REQUIRED_INPUTS, received_inputs)
      set_as_invalid!
      return false
    end

    unless valid_role_slug?(@role_slug)
      set_as_invalid!
      return false
    end

    user = invited_user(@user_email, @first_name, @first_last_name, @second_last_name)
    user_enterprise = create_user_enterprise(user, @enterprise)
    assign_role_to_user_enterprise(user_enterprise, @role_slug)

    invitation_service = ::Users::SendUserEnterpriseInvitation.new(user:, enterprise: @enterprise)
    invitation_service.call

    unless invitation_service.valid?
      raise StandardError, invitation_service.errors_message
    end

    set_as_valid!
  rescue => e
    add_error("Error al invitar usuario: #{e.message}")
    set_as_invalid!
  end

  private

  # Validates if the role slug is valid in Role model
  #
  # @param role_slug [String]
  #
  # @return [Boolean]
  def valid_role_slug?(role_slug)
    allowed_roles = Role.slugs.values
    unless allowed_roles.include?(role_slug.to_s)
      add_error("El rol '#{role_slug}' no es válido. Roles permitidos: #{allowed_roles.join(', ')}")
      return false
    end
    true
  end

  # Retrieves existing user if exists, otherwise creates a new user
  # @return [User]
  def invited_user(user_email, first_name, first_last_name, second_last_name)
    existing_user || User.create!(
        email_address: user_email,
        first_name: first_name,
        first_last_name: first_last_name,
        second_last_name: second_last_name,
        status: :pending,
        platform_role: :standard
    )
  end

  # Creates user enterprise relationship if it doesn't exist
  # @return [UserEnterprise]
  def create_user_enterprise(user, enterprise)
    raise StandardError, "User already exists in this enterprise" if existing_user_enterprise

    UserEnterprise.create!(user: user, enterprise: enterprise)
  end

  # Assigns role to user enterprise
  #
  # @param user_enterprise [UserEnterprise]
  # @param role_slug [String]
  #
  # @return [UserEnterpriseRole]
  def assign_role_to_user_enterprise(user_enterprise, role_slug)
    role = Role.find_by!(slug: role_slug)
    UserEnterpriseRole.create!(user_enterprise: user_enterprise, role: role)
  end

  # Retrieves existing user if exists
  # @return [User, nil]
  def existing_user
    @existing_user ||= User.find_by(email_address: @user_email)
  end

  # Retrieves existing user enterprise relationship if exists
  # @return [UserEnterprise, nil]
  def existing_user_enterprise
    @existing_user_enterprise ||= UserEnterprise.find_by(user: existing_user, enterprise: @enterprise)
  end
end
