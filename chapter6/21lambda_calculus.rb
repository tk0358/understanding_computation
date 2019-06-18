class LCVariable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    to_s
  end

  def replace(name, replacement)
    if self.name == name
      replacement
    else
      self
    end
  end
end

class LCFunction < Struct.new(:parameter, :body)
  def to_s
    "-> #{parameter} { #{body} }"
  end

  def inspect
    to_s
  end

  def replace(name, replacement)
    if parameter == name
      self
    else
      LCFunction.new(parameter, body.replace(name, replacement))
    end
  end

  def call(argument)
    body.replace(parameter, argument)
  end
end

class LCCall < Struct.new(:left, :right)
  def to_s
    "#{left}[#{right}]"
  end

  def inspect
    to_s
  end

  def replace(name, replacement)
    LCCall.new(left.replace(name, replacement), right.replace(name, replacement))
  end
end

function =
  LCFunction.new(:x,
    LCFunction.new(:y,
      LCCall.new(LCVariable.new(:x), LCVariable.new(:y))  
    )
  )
argument = LCFunction.new(:z, LCVariable.new(:z))
function.call(argument)