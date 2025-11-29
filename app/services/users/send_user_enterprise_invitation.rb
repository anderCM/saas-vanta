class Users::SendUserEnterpriseInvitation < BaseService
  REQUIRED_INPUTS = %w[user enterprise].freeze

  def initialize(user:, enterprise:, **kwargs)
    super()
    @user = user
    @enterprise = enterprise
    @kwargs = kwargs
  end

  def call
    return false unless valid_required_inputs?(REQUIRED_INPUTS, { user: @user, enterprise: @enterprise })

    @user.generate_invitation_token!

    UserMailer.with(user: @user, enterprise: @enterprise).invitation_email.deliver_later
    set_as_valid!
  rescue => e
    add_error("Error al enviar invitación: #{e.message}")
    set_as_invalid!
  end
end
