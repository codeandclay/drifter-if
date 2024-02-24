require 'bundler'
Bundler.require

require 'minitest/autorun'
require 'pry'

require_relative "../lib/event"
require_relative "../lib/action"

class DummyAction < Action
  def command
    -> { subject.act }
  end
end

class DummySubject
  attr_accessor :counter

  def initialize
    @counter = 0
  end

  def act
    self.counter += 1
  end
end

describe Action do
  let(:action) { DummyAction.new(DummySubject.new) }

  it "Should run successfully" do
    assert_equal :success, action.run
  end
end

describe Event do
  let(:subject) { DummySubject.new }
  let(:action) { DummyAction.new(subject) }
  let(:event) { Event.new(actions: [action] )}

  let(:before_event_count) { [*1..10].sample }
  let(:after_event_count) { [*1..10].sample }

  let(:before_events) { Array.new(before_event_count) { Event.new(actions: [action]) } }
  let(:after_events) { Array.new(after_event_count) { Event.new(actions: [action]) } }

  it "Should run an event" do
    initial_count = subject.counter
    event.run

    assert_equal initial_count + event.actions.count, subject.counter
  end

  it "Should run an event before firing" do
    initial_count = subject.counter
    wrapping_events = WrappingEvents.new(before: before_events)

    event = Event.new(actions: [action], wrap_with: wrapping_events)
                 .tap { |obj| obj.run }


    total_actions =
      [initial_count, before_event_count, event.actions.count].sum

    assert_equal total_actions, subject.counter
  end

  it "Should run an event after firing" do
    initial_count = subject.counter
    wrapping_events = WrappingEvents.new(after: after_events)

    event = Event.new(actions: [action], wrap_with: wrapping_events )
                 .tap { |obj| obj.run }

    total_actions =
      [initial_count, after_event_count, event.actions.count].sum

    assert_equal total_actions, subject.counter
  end

  it "Should run an event before and after firing" do
    initial_count = subject.counter

    wrapping_events = WrappingEvents.new before: before_events, after: after_events

    event = Event.new(actions: [action], wrap_with: wrapping_events ).tap { |obj| obj.run }

    total_actions =
      [initial_count, before_event_count, after_event_count, event.actions.count].sum

    assert_equal total_actions, subject.counter
  end

  it "Should run multiple actions" do
    initial_count = subject.counter
    total_actions = [*1..10].sample

    actions = Array.new(total_actions) { action }
    Event.new(actions: actions).tap { |obj| obj.run }

    assert_equal initial_count + total_actions, subject.counter
  end

  it "Should run without main action" do
    initial_count = subject.counter

    wrapping_events = WrappingEvents.new before: before_events, after: after_events

    Event.new(actions: [], wrap_with: wrapping_events ).tap { |obj| obj.run }

    total_count =
      [ initial_count, before_event_count, after_event_count].sum

    assert_equal total_count, subject.counter
  end

  it "Should run an Event if passed to actions" do
    initial_count = subject.counter

    event_count = [*1..10].sample
    event_count.times { Event.new(actions: [event]).tap { |obj| obj.run } }

    assert_equal initial_count + event_count, subject.counter
  end
end
