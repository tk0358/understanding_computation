require 'stringio'

def evaluate(program, input)
  old_stdin, old_stdout = $stdin, $stdout
  $stdin, $stdout = StringIO.new(input), (output = StringIO.new)

  begin
    eval program
  rescue Exception => e
    output.puts(e)
  ensure
    $stdin, $stdout = old_stdin, old_stdout
  end

  output.string
end

def evaluate_on_itself(program)
  evaluate(program, program)
end