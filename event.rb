require 'bundler'
Bundler.require

require 'minitest/autorun'
require 'pry'

class Action
  attr_reader :executed

  def initialize
    @executed = false
  end

  def run
    @executed = true
    :success
  end

  def executed?
    executed
  end

  def reset
    @executed = false
  end
end

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

# Tests

describe Action do
  let(:action) { Action.new }

  it "Should run successfully" do
    assert_equal :success, action.run
  end

  it "Should not be executed when not run" do
    refute action.executed?
  end

  it "Should be executed when run" do
    action.run
    assert action.executed?
  end

  it "Should not be executed once run and reset" do
    action.run
    action.reset

    refute action.executed?
  end

  it "Should not be executed when reset before running" do
    action.reset

    refute action.executed?
  end
end

describe Event do
  let(:action) { Action.new }
  let(:event) { Event.new(actions: [action] )}

  it "Should run an event" do
    event.fire

    assert action.executed?
  end

  it "Should run an event before firing" do
    before_action = Action.new
    before_event = Event.new(actions: [before_action] )
    event = Event.new(actions: [action], options: { before_events: [ before_event ] } )

    refute before_action.executed?
    event.fire

    assert action.executed?
    assert before_action.executed?
  end

  it "Should run an event after firing" do
    after_action = Action.new
    after_event = Event.new(actions: [after_action] )
    event = Event.new(actions: [action], options: { after_events: [ after_event ] } )

    refute after_action.executed?
    event.fire

    assert action.executed?
    assert after_action.executed?
  end

  it "Should run an event before and after firing" do
    before_action = Action.new
    before_event = Event.new(actions: [before_action] )

    after_action = Action.new
    after_event = Event.new(actions: [after_action] )
    
    event = Event.new(actions: [action], options: {
      before_events: [ before_event ],
      after_events: [ after_event ]
    } )

    refute before_action.executed?
    refute action.executed?
    refute after_action.executed?

    event.fire

    assert before_action.executed?
    assert action.executed?
    assert after_action.executed?
  end

  it "Should run multiple actions" do
    total_actions = 5

    actions = Array.new(total_actions) { Action.new }
    event = Event.new(actions: actions).tap { |obj| obj.fire }

    assert_equal total_actions, event.actions.count { |action| action.executed? }
  end

  it "Should register new action after creation" do
    original_action_count = event.actions.count

    event.register(Action.new)

    assert_equal original_action_count + 1, event.actions.count
  end

  it "Should remove actions from actions" do
    original_action_count = event.actions.count

    event.remove(action)

    assert_equal original_action_count - 1, event.actions.count
  end

  it "Actions should be unique" do
    original_action_count = event.actions.count

    event.register(action)

    assert_equal original_action_count, event.actions.count
  end

  it "Should register new before events" do
    before_action = Action.new
    before_event = Event.new(actions: [before_action] )
    original_before_event_count = event.before_events.count

    event.register_before(before_event)

    assert_equal original_before_event_count + 1, event.before_events.count
  end

  it "Should register new after events" do
    after_action = Action.new
    after_event = Event.new(actions: [after_action] )
    original_after_event_count = event.after_events.count

    event.register_after(after_event)

    assert_equal original_after_event_count + 1, event.after_events.count
  end

  it "Remove before and after events" do
    original_before_event_count = event.before_events.count
    original_after_event_count = event.after_events.count

    before_action = Action.new
    before_event = Event.new(actions: [before_action] )

    after_action = Action.new
    after_event = Event.new(actions: [after_action] )

    event.register_before(before_event)
    event.register_after(after_event)

    event.remove_before(before_event)
    event.remove_after(after_event)

    assert_equal original_before_event_count, event.before_events.count
    assert_equal original_after_event_count, event.after_events.count
  end

  it "Events should be unique" do
    original_before_event_count = event.before_events.count
    original_after_event_count = event.after_events.count

    before_action = Action.new
    before_event = Event.new(actions: [before_action] )

    after_action = Action.new
    after_event = Event.new(actions: [after_action] )

    10.times do
      event.register_before(before_event)
    end

    10.times do
      event.register_after(after_event)
    end

    event.remove_before(before_event)
    event.remove_after(after_event)

    assert_equal original_before_event_count, event.before_events.count
    assert_equal original_after_event_count, event.after_events.count
  end

  it "Will always return an array even when all events removed" do
    before_action = Action.new
    before_event = Event.new(actions: [before_action] )

    10.times do
      event.register_before(before_event)
    end

    20.times do
      event.remove_before(before_event)
    end

    assert_equal [], event.before_events
  end
end
