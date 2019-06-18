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

expression = LCVariable.new(:x)
expression.replace(:x, LCFunction.new(:y, LCVariable.new(:y)))
expression.replace(:z, LCFunction.new(:y, LCVariable.new(:y)))

expression = 
  LCCall.new(
    LCCall.new(
      LCCall.new(
        LCVariable.new(:a),
        LCVariable.new(:b)
      ),
      LCVariable.new(:c)
    ),
    LCVariable.new(:b)
  )
expression.replace(:a, LCVariable.new(:x))
expression.replace(:b, LCFunction.new(:x, LCVariable.new(:x)))