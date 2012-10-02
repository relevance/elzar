module ShellInteractionHelpers
  def capture_stderr(&block)
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  # wrapper around raise_error that captures stderr
  def should_abort_with(msg)
    capture_stderr do
      expect do
        yield
      end.to raise_error SystemExit, msg
    end
  end
end

