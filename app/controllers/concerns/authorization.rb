# Authorization concern for controllers
#
# Provides methods to authorize actions based on policies.
module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :policy, :policy_context
  end

  # Error raised when user is not authorized
  class NotAuthorizedError < StandardError
    attr_reader :policy, :action, :record

    def initialize(options = {})
      @policy = options[:policy]
      @action = options[:action]
      @record = options[:record]

      message = options[:message] || "No tienes permisos para realizar esta accion"
      super(message)
    end
  end

  # Authorize the current action for a record
  #
  # @param record [Object] the record to authorize
  # @param action [Symbol, nil] the action to authorize (defaults to "#{action_name}?")
  # @raise [NotAuthorizedError] if the user is not authorized
  #
  # @return [Boolean] true if authorized
  def authorize(record, action = nil)
    action ||= "#{action_name}?"
    policy_instance = policy(record)

    unless policy_instance.public_send(action)
      raise NotAuthorizedError.new(
        policy: policy_instance,
        action: action,
        record: record
      )
    end

    true
  end

  # Get the policy instance for a record
  #
  # @param record [Object] the record to get the policy for
  # @return [ApplicationPolicy] the policy instance
  #
  # @example
  #   policy(@product).edit?  # => true/false
  #
  def policy(record)
    policy_class = find_policy_class(record)
    policy_class.new(policy_context, record)
  end

  # Build the policy context with current user and enterprise
  #
  # @return [PolicyContext]
  def policy_context
    @policy_context ||= PolicyContext.new(Current.user, current_enterprise)
  end

  private

  # Find the policy class for a record
  #
  # @param record [Object] the record to find the policy for
  # @return [Class] the policy class
  #
  # @example
  #   find_policy_class(@product)  # => ProductPolicy
  #   find_policy_class(Product)   # => ProductPolicy
  #
  def find_policy_class(record)
    klass = case record
    when Class
      record
    when Array
      record.last.class
    else
      record.class
    end

    "#{klass}Policy".constantize
  rescue NameError
    raise "No se encontro la politica para #{klass}"
  end
end
