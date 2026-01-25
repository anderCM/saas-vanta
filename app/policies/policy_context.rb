# Context object for policies containing user and enterprise information
#
# This is passed to policies instead of just the user, allowing policies
# to access both the current user and the current enterprise context.
class PolicyContext
  attr_reader :user, :enterprise

  def initialize(user, enterprise)
    @user = user
    @enterprise = enterprise
  end
end
