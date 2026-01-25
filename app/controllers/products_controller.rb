class ProductsController < ApplicationController
  before_action :require_enterprise_selected
  before_action :set_product, only: %i[show edit update destroy]

  def index
    authorize Product
    products = current_enterprise.products.includes(:provider).order(created_at: :desc)
    @pagy, @products = pagy(products)
  end

  def show
    authorize @product
  end

  def new
    authorize Product
    @product = current_enterprise.products.build
    @providers = current_enterprise.providers
  end

  def create
    authorize Product
    @product = current_enterprise.products.build(product_params)

    if @product.save
      redirect_to @product, notice: "Producto creado exitosamente."
    else
      @providers = current_enterprise.providers
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
    @providers = current_enterprise.providers
  end

  def update
    authorize @product

    if @product.update(product_params)
      redirect_to @product, notice: "Producto actualizado exitosamente."
    else
      @providers = current_enterprise.providers
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    @product.destroy
    redirect_to products_path, notice: "Producto eliminado exitosamente."
  end

  private

  def require_enterprise_selected
    return if current_enterprise.present?

    redirect_to enterprises_path, alert: "Debes seleccionar una empresa primero."
  end

  def set_product
    @product = current_enterprise.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :sku,
      :source_type,
      :unit,
      :units_per_package,
      :buy_price,
      :sell_cash_price,
      :sell_credit_price,
      :stock,
      :status,
      :provider_id
    )
  end
end
