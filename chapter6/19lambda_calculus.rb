class LCVariable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    to_s
  end
end

class LCFunction < Struct.new(:parameter, :body)
  def to_s
    "-> #{parameter} { #{body} }"
  end

  def inspect
    to_s
  end
end

class LCCall < Struct.new(:left, :right)
  def to_s
    "#{left}[#{right}]"
  end

  def inspect
    to_s
  end
end

one =
  LCFunction.new(:p,
    LCFunction.new(:x,
      LCCall.new(LCVariable.new(:p), LCVariable.new(:x))
    )
  )

increment =
  LCFunction.new(:n,
    LCFunction.new(:p,
      LCFunction.new(:x,
        LCCall.new(
          LCVariable.new(:p),
          LCCall.new(
            LCCall.new(LCVariable.new(:n), LCVariable.new(:p)),
            LCVariable.new(:x)
          )
        )  
      )
    )
  )

add =
  LCFunction.new(:m, 
    LCFunction.new(:n,
      LCCall.new(LCCall.new(LCVariable.new(:n), increment), LCVariable.new(:m))  
    )
  )

# 参照
# ADD      = -> m { -> n { n[INCREMENT][m] } }