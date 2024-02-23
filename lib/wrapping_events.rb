class WrappingEvents
  attr_accessor :before, :after

  def initialize(before: [], after: [])
    @before = before
    @after = after
  end

  def run_around
    before.each &:run

    yield

    after.each &:run
  end
end
