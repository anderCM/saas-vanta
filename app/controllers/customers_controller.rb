class CustomersController < ApplicationController
  before_action :require_enterprise_selected
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    authorize Customer
    customers = current_enterprise.customers.order(created_at: :desc)
    @pagy, @customers = pagy(customers)
  end

  def show
    authorize @customer
  end

  def new
    authorize Customer
    @customer = current_enterprise.customers.build
  end

  def create
    authorize Customer
    @customer = current_enterprise.customers.build(customer_params)

    if @customer.save
      redirect_to @customer, notice: "Cliente creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @customer
  end

  def update
    authorize @customer

    if @customer.update(customer_params)
      redirect_to @customer, notice: "Cliente actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @customer
    @customer.destroy
    redirect_to customers_path, notice: "Cliente eliminado exitosamente."
  end

  private

  def require_enterprise_selected
    return if current_enterprise.present?

    redirect_to enterprises_path, alert: "Debes seleccionar una empresa primero."
  end

  def set_customer
    @customer = current_enterprise.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :name,
      :tax_id,
      :tax_id_type,
      :email,
      :phone_number,
      :address,
      :credit_limit,
      :payment_terms
    )
  end
end
