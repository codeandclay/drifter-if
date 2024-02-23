class Action
  attr_reader :executed, :subject

  def initialize(subject)
    @subject = subject
  end

  def run
    # Do something to subject and return status
    :success
  end
end
