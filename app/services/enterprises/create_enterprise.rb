class Enterprises::CreateEnterprise < BaseService
  attr_reader :enterprise
  def initialize(user_id:, **kwargs)
    super()
    @user_id = user_id
    @kwargs = kwargs
    @enterprise = nil
  end

  def call
    validate_user(@user_id)
    new_enterprise = Enterprise.new(@kwargs)
    new_enterprise.status = "active"
    new_enterprise.save!
    @enterprise = new_enterprise
    set_as_valid!
  rescue => e
    add_error("Error al crear la empresa: #{e.message}")
    set_as_invalid!
  end

  private

  def validate_user(user_id)
    user = User.find(user_id)
    raise StandardError, "El usuario no se encuentra activo" unless user.active?
    raise StandardError, "El usuario no tiene los permisos necesarios" unless user.super_admin?
  end
end
