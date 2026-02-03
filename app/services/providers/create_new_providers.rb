class Providers::CreateNewProviders < BulkCreateService
  private

  def model_class
    Provider
  end
end
