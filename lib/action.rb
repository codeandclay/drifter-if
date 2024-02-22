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
