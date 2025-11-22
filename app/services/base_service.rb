class BaseService
  attr_reader :errors

  def initialize
    @errors = []
    @valid = true
  end

  # Main method to execute the service logic
  # Subclasses must implement this method
  def call
    raise NotImplementedError, "#{self.class} must implement #call method"
  end

  # Add an error and mark service as invalid
  # @param message [String] Error message to add
  def add_error(message)
    @errors << message
    Rails.logger.error("[#{self.class.name}] #{message}")
  end

  # Add multiple errors at once
  # @param messages [Array<String>] Array of error messages
  def add_errors(messages)
    messages.each { |message| add_error(message) }
  end

  # Check if service execution was successful
  # @return [Boolean]
  def valid?
    @valid
  end

  # Get all errors as a single string
  # @param separator [String] Separator between errors
  # @return [String]
  def errors_message(separator: ", ")
    @errors.join(separator)
  end

  # Clear all errors and mark as valid
  def reset!
    @errors = []
    @valid = true
  end

  def set_as_valid!
    @valid = true
  end

  def set_as_invalid!
    @valid = false
  end

  # Validate that all required inputs are present
  # @param required_inputs [Array<String, Symbol>] List of required input names
  # @param received_inputs [Hash] Hash of received inputs (usually instance variables)
  # @return [Boolean] true if all required inputs are present, false otherwise
  def valid_required_inputs?(required_inputs, received_inputs)
    missing_inputs = []

    required_inputs.each do |input_name|
      key = input_name.to_sym
      value = received_inputs[key]

      missing_inputs << input_name if value.nil?
    end

    if missing_inputs.any?
      missing_inputs.each do |input|
        add_error("#{input.to_s.capitalize} es requerido")
      end

      return false
    end

    true
  end
end
