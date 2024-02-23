class Event
  attr_accessor :actions, :wrapping_events

  def initialize(actions:, wrap: {})
    @actions = actions
    @wrapping_events = { before: [] , after: [] }.merge wrap
  end

  def fire
    fire_before_events

    actions.each(&:run)

    fire_after_events
  end

  def fire_before_events
    wrapping_events[:before].each &:fire
  end

  def fire_after_events
    wrapping_events[:after].each &:fire
  end
end
