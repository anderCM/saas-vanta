class Products::CreateProducts < BaseService
  BATCH_SIZE = 1_000

  # products is not a collection of Product model
  # It is a collection of hashes to be inserted into the database
  def initialize(products:, enterprise:)
    super()
    @products = products
    @enterprise = enterprise
  end

  def call
    @products.each_slice(BATCH_SIZE) do |batch|
      batch.each do |attrs|
        product = Product.new(attrs.merge(enterprise: @enterprise))

        unless product.save
          @errors << { name: product.name, errors: product.errors.full_messages }
        end
      end
    end

    return set_as_valid! if @errors.empty?

    set_as_invalid!
  rescue ActiveRecord::ActiveRecordError => e
    add_error(e.message)
    set_as_invalid!
  end
end
