require 'bundler'
Bundler.require

require 'minitest/autorun'
require 'pry'

require_relative "../lib/event"
require_relative "../lib/action"

describe Action do
  let(:action) { Action.new }

  it "Should run successfully" do
    assert_equal :success, action.run
  end
end

describe Event do
  let(:action) { Action.new }
  let(:event) { Event.new(actions: [action] )}

  it "Should run an event" do
    skip

    event.fire

    # assert action.executed?
  end

  it "Should run an event before firing" do
    skip
  end

  it "Should run an event after firing" do
    skip
  end

  it "Should run an event before and after firing" do
    skip
  end

  it "Should run multiple actions" do
    skip

    total_actions = 5

    actions = Array.new(total_actions) { Action.new }
    event = Event.new(actions: actions).tap { |obj| obj.fire }

    # assert_equal total_actions, event.actions.count { |action| action.executed? }
  end
end
