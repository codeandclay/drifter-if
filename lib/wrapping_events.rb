class WrappingEvents
  attr_accessor :before, :after

  def initialize(before: [], after: [])
    @before = before
    @after = after
  end

  def fire_around
    before.each &:fire

    yield

    after.each &:fire
  end
end
