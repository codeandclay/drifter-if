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
    raise NotImplementedError, "Class must supply a command to run"
  end
end
