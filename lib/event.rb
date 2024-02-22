class Event
  attr_accessor :actions, :before_events, :after_events

  def initialize(actions:, options: { before_events:, after_events: })
    @actions = actions
    @before_events = options[:before_events] ||= []
    @after_events = options[:after_events] ||= []
  end

  def method_missing(method_called, arg)
    arrays = {
      register_before: before_events,
      register_after: after_events,
      remove_before: before_events,
      remove_after: after_events
    }

    raise ArgumentError, "Method not found" unless arrays.keys.include? method_called

    send method_called.to_s.split('_')[0].to_sym, arrays[method_called], arg
  end

  def register(collection = actions, item)
    collection << item unless collection.include? item
  end

  def remove(collection = actions, item_to_remove)
    collection.reject! { |item| item == item_to_remove }
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
