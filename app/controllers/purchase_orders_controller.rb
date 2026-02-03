class PurchaseOrdersController < ApplicationController
  before_action :require_enterprise_selected
  before_action :set_purchase_order, only: %i[show edit update destroy confirm receive cancel pdf]

  def index
    authorize PurchaseOrder
    purchase_orders = current_enterprise.purchase_orders
                                        .includes(:provider, :created_by)
                                        .order(created_at: :desc)
    @pagy, @purchase_orders = pagy(purchase_orders)
  end

  def show
    authorize @purchase_order
  end

  def new
    authorize PurchaseOrder
    @purchase_order = current_enterprise.purchase_orders.build(
      code: generate_next_code,
      issue_date: Date.current,
      created_by: Current.user
    )
  end

  def create
    authorize PurchaseOrder

    @purchase_order = current_enterprise.purchase_orders.build(purchase_order_params)
    @purchase_order.status = :confirmed
    @purchase_order.created_by = Current.user

    unless purchase_order_params[:items_attributes].present?
      @purchase_order.errors.add(:base, "Debes agregar al menos un producto")
      return render :new, status: :unprocessable_entity
    end

    if @purchase_order.save
      redirect_to @purchase_order, notice: "Orden de compra creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @purchase_order

    unless @purchase_order.can_edit?
      redirect_to @purchase_order, alert: "No se puede editar una orden que no esta en borrador."
    end
  end

  def update
    authorize @purchase_order

    unless @purchase_order.can_edit?
      redirect_to @purchase_order, alert: "No se puede editar una orden que no esta en borrador."
      return
    end

    if @purchase_order.update(purchase_order_params)
      redirect_to @purchase_order, notice: "Orden de compra actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @purchase_order

    if @purchase_order.draft?
      @purchase_order.destroy
      redirect_to purchase_orders_path, notice: "Orden de compra eliminada."
    else
      redirect_to @purchase_order, alert: "Solo se pueden eliminar ordenes en borrador."
    end
  end

  # Status transitions
  def confirm
    authorize @purchase_order

    if @purchase_order.confirm!
      redirect_to @purchase_order, notice: "Orden de compra confirmada."
    else
      redirect_to @purchase_order, alert: "No se pudo confirmar la orden."
    end
  end

  def receive
    authorize @purchase_order

    if @purchase_order.receive!
      redirect_to @purchase_order, notice: "Orden recibida. Stock actualizado."
    else
      redirect_to @purchase_order, alert: "No se pudo marcar como recibida."
    end
  end

  def cancel
    authorize @purchase_order

    if @purchase_order.cancel!
      redirect_to @purchase_order, notice: "Orden de compra cancelada."
    else
      redirect_to @purchase_order, alert: "No se pudo cancelar la orden."
    end
  end

  def prefill
    authorize PurchaseOrder

    service = PurchaseOrders::HistoricalDataRecoverer.new(
      enterprise: current_enterprise,
      customer_id: params[:customer_id]
    )
    service.call

    render json: service.last_order_data
  end

  def pdf
    authorize @purchase_order, :show?

    html = render_to_string(template: "purchase_orders/pdf", layout: "layouts/pdf")

    pdf_data = WickedPdf.new.pdf_from_string(html,
      page_size: "A4",
      margin: { top: 10, bottom: 10, left: 10, right: 10 },
      print_media_type: true
    )

    send_data pdf_data,
      filename: "#{@purchase_order.enterprise.comercial_name.parameterize}-#{@purchase_order.code}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end

  private

  def require_enterprise_selected
    return if current_enterprise.present?

    redirect_to enterprises_path, alert: "Debes seleccionar una empresa primero."
  end

  def set_purchase_order
    @purchase_order = current_enterprise.purchase_orders.find(params[:id])
  end

  def generate_next_code
    current_year = Date.current.year
    last_order = current_enterprise.purchase_orders
      .where("code LIKE ?", "OC-%-#{current_year}")
      .order(created_at: :desc)
      .first
    last_number = last_order&.code&.split("-")&.second.to_i || 0
    "OC-#{(last_number + 1).to_s.rjust(4, '0')}-#{current_year}"
  end

  def purchase_order_params
    params.require(:purchase_order).permit(
      :code,
      :provider_id,
      :customer_id,
      :destination_id,
      :issue_date,
      :expected_date,
      :notes,
      items_attributes: [ :id, :product_id, :quantity, :unit_price, :_destroy ]
    )
  end
end
