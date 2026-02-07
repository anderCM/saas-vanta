class SalesController < ApplicationController
  include PdfExportable

  before_action :require_enterprise_selected
  before_action :set_sale, only: %i[show edit update destroy confirm cancel pdf generate_purchase_orders]

  def index
    authorize Sale
    sales = current_enterprise.sales
                              .includes(:customer, :seller, :created_by)
                              .order(created_at: :desc)
    @pagy, @sales = pagy(sales)
  end

  def show
    authorize @sale
  end

  def new
    authorize Sale
    @sale = current_enterprise.sales.build(
      code: Sale.generate_next_code(current_enterprise),
      issue_date: Date.current,
      created_by: Current.user,
      seller: Current.user
    )
    @show_seller_selector = !current_user_is_seller_only?
  end

  def create
    authorize Sale

    @sale = current_enterprise.sales.build(sale_params)
    @sale.status = :pending
    @sale.created_by = Current.user

    if current_user_is_seller_only?
      @sale.seller = Current.user
    end

    unless sale_params[:items_attributes].present?
      @sale.errors.add(:base, "Debes agregar al menos un producto")
      @show_seller_selector = !current_user_is_seller_only?
      return render :new, status: :unprocessable_entity
    end

    if @sale.save
      redirect_to @sale, notice: "Venta creada exitosamente."
    else
      @show_seller_selector = !current_user_is_seller_only?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @sale
    @show_seller_selector = !current_user_is_seller_only?

    unless @sale.can_edit?
      redirect_to @sale, alert: "No se puede editar una venta que no esta pendiente."
    end
  end

  def update
    authorize @sale

    unless @sale.can_edit?
      redirect_to @sale, alert: "No se puede editar una venta que no esta pendiente."
      return
    end

    update_params = sale_params
    if current_user_is_seller_only?
      update_params = update_params.except(:seller_id)
    end

    if @sale.update(update_params)
      redirect_to @sale, notice: "Venta actualizada exitosamente."
    else
      @show_seller_selector = !current_user_is_seller_only?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @sale

    if @sale.pending?
      @sale.destroy
      redirect_to sales_path, notice: "Venta eliminada."
    else
      redirect_to @sale, alert: "Solo se pueden eliminar ventas pendientes."
    end
  end

  def confirm
    authorize @sale

    if @sale.confirm!
      redirect_to @sale, notice: "Venta confirmada. Stock actualizado."
    else
      redirect_to @sale, alert: "No se pudo confirmar la venta."
    end
  end

  def cancel
    authorize @sale

    if @sale.cancel!
      redirect_to @sale, notice: "Venta cancelada."
    else
      redirect_to @sale, alert: "No se pudo cancelar la venta."
    end
  end

  def generate_purchase_orders
    authorize @sale

    if @sale.generate_purchase_orders!(created_by: Current.user)
      redirect_to @sale, notice: "Ordenes de compra generadas exitosamente."
    else
      redirect_to @sale, alert: "No se pudieron generar las ordenes de compra."
    end
  end

  def pdf
    authorize @sale, :show?

    generate_pdf(@sale, template: "sales/pdf")
  end

  private

  def require_enterprise_selected
    return if current_enterprise.present?

    redirect_to enterprises_path, alert: "Debes seleccionar una empresa primero."
  end

  def set_sale
    @sale = current_enterprise.sales.find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(
      :code,
      :customer_id,
      :seller_id,
      :destination_id,
      :issue_date,
      :notes,
      items_attributes: [ :id, :product_id, :quantity, :unit_price, :_destroy ]
    )
  end

  def current_user_is_seller_only?
    roles = Current.user.roles_for(current_enterprise)
    roles.include?("seller") && !roles.include?("super_admin") && !roles.include?("admin") && !Current.user.super_admin?
  end
end
