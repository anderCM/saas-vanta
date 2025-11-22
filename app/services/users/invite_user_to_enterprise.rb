class Users::InviteUserToEnterprise < BaseService
  REQUIRED_INPUTS = %w[enterprise user_email first_name first_last_name second_last_name].freeze

  def initialize(enterprise:, user_email:, first_name:, first_last_name:, second_last_name:, **kwargs)
    super()
    @enterprise = enterprise
    @user_email = user_email
    @first_name = first_name
    @first_last_name = first_last_name
    @second_last_name = second_last_name
    @kwargs = kwargs
  end

  def call
    received_inputs = { enterprise: @enterprise, user_email: @user_email, first_name: @first_name, first_last_name: @first_last_name, second_last_name: @second_last_name }
    return false unless valid_required_inputs?(REQUIRED_INPUTS, received_inputs)

    user = invited_user(@user_email, @first_name, @first_last_name, @second_last_name)
    create_user_enterprise(user, @enterprise)

    invitation_service = ::Users::SendUserEnterpriseInvitation.new(user:, enterprise: @enterprise)
    invitation_service.call

    raise StandardError, invitation_service.errors unless invitation_service.valid?

    set_as_valid!
  rescue => e
    add_error("Error al invitar usuario: #{e.message}")
    set_as_invalid!
  end

  private

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
