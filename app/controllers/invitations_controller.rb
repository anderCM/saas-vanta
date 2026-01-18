class InvitationsController < ApplicationController
  allow_unauthenticated_access only: [ :edit, :update ]
  layout "auth"

  before_action :set_user_by_token

  def edit
    # Renders the form to set password
  end

  def update
    if @user.accept_invitation!(user_params[:password], user_params[:password_confirmation])
      start_new_session_for @user
      redirect_to root_path, notice: "Tu cuenta ha sido activada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by(invitation_token: params[:token])

    unless @user && @user.invitation_valid?
      redirect_to login_path, alert: "El enlace de invitación es inválido o ha expirado."
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
