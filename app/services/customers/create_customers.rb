class Customers::CreateCustomers < BulkCreateService
  private

  def model_class
    Customer
  end
end
