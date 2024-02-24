class Action
  attr_reader :executed, :subject

  def initialize(subject)
    @subject = subject
  end

  def run
    command.call
    :success
  end

  def command
    -> {}
  end
end
