class ProviderProductsController < ApplicationController
  before_action :require_enterprise_selected

  def index
    provider = current_enterprise.providers.find(params[:provider_id])
    query = params[:q].to_s.strip

    @products = if query.present?
      provider.products
              .where("LOWER(name) LIKE :query OR LOWER(sku) LIKE :query", query: "%#{query.downcase}%")
              .order(:name)
              .limit(20)
    else
      provider.products.order(:name).limit(20)
    end

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def require_enterprise_selected
    return if current_enterprise.present?

    head :forbidden
  end
end
