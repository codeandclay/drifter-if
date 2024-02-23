require_relative './wrapping_events'

class Event
  attr_accessor :actions, :wrapping_events

  def initialize(actions:, wrap_with: WrappingEvents.new())
    @actions = actions
    @wrapping_events = wrap_with
  end

  def run
    wrapping_events.run_around do
      actions.each &:run
    end
  end
end
