class Event
  attr_accessor :actions, :before_events, :after_events

  def initialize(actions:, options: { before_events:, after_events: })
    @actions = actions
    @before_events = options[:before_events] ||= []
    @after_events = options[:after_events] ||= []
  end

  def fire
    fire_before_events

    actions.each(&:run)

    fire_after_events
  end

  def fire_before_events
    before_events.each &:fire
  end

  def fire_after_events
    after_events.each &:fire
  end
end
