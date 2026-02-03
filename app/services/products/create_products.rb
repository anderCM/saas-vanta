class Products::CreateProducts < BulkCreateService
  private

  def model_class
    Product
  end
end
