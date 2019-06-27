class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    self
  end

  def type(context)
    Type::NUMBER
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    self
  end

  def type(context)
    Type::BOOLEAN
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    environment[name]
  end

  def type(context)
    context[name]
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end

  def type(context)
    if left.type(context) == Type::NUMBER && right.type(context) == Type::NUMBER
      Type::NUMBER
    end
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end

  def type(context)
    if left.type(context) == Type::NUMBER && right.type(context) == Type::NUMBER
      Type::NUMBER
    end
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end

  def type(context)
    if left.type(context) == Type::NUMBER && right.type(context) == Type::NUMBER
      Type::BOOLEAN
    end
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    environment.merge( { name => expression.evaluate(environment) })
  end

  def type(context)
    if context[name] == expression.type(context)
      Type::VOID
    end
  end
end

class DoNothing
  def to_s
    'do-nothing'
  end

  def inspect
    "<<#{self}>>"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def evaluate(environment)
    environment
  end

  def type(context)
    Type::VOID
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end

  def type(context)
    if condition.type(context) == Type::BOOLEAN &&
      consequence.type(context) == Type::VOID &&
      alternative.type(context) == Type::VOID
      Type::VOID
    end
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first}; #{second}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end

  def type(context)
    if first.type(context) == Type::VOID && second.type(context) == Type::VOID
      Type::VOID
    end
  end
end

class While < Struct.new(:condition, :body)
  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end

  def type(context)
    if condition.type(context) == Type::BOOLEAN && body.type(context) == Type::VOID
      Type::VOID
    end
  end
end

class Type < Struct.new(:name)
  NUMBER, BOOLEAN = [:number, :boolean].map { |name| new(name) }
  VOID = new(:void)

  def inspect
    "#<Type #{name}>"
  end
end

# Add.new(Number.new(1), Number.new(2)).evaluate({})
# Add.new(Number.new(1), Boolean.new(true)).evaluate({})

# Add.new(Number.new(1), Number.new(2)).type
# Add.new(Number.new(1), Boolean.new(true)).type
# LessThan.new(Number.new(1), Number.new(2)).type
# LessThan.new(Number.new(1), Boolean.new(true)).type

expression = Add.new(Variable.new(:x), Variable.new(:y))
expression.type({})
expression.type({ x: Type::NUMBER, y: Type::NUMBER })
expression.type({ x: Type::NUMBER, y: Type::BOOLEAN })

If.new(
  LessThan.new(Number.new(1), Number.new(2)), DoNothing.new, DoNothing.new
).type({})

If.new(
  Add.new(Number.new(1), Number.new(2)), DoNothing.new, DoNothing.new
).type({})

While.new(Variable.new(:x), DoNothing.new).type({ x: Type::BOOLEAN })
While.new(Variable.new(:x), DoNothing.new).type({ x: Type::NUMBER })

statement =
  While.new(
    LessThan.new(Variable.new(:x), Number.new(5)),
    Assign.new(:x, Add.new(Variable.new(:x), Number.new(3)))
  )
statement.type({})
statement.type({ x: Type::NUMBER })
statement.type({ x: Type::BOOLEAN })

statement =
  Sequence.new(
    Assign.new(:x, Number.new(0)),
    While.new(
      Boolean.new(true),
      Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
    )
  )
statement.type({ x: Type::NUMBER })
# statement.evaluate({})

statement = Sequence.new(statement, Assign.new(:x, Boolean.new(true)))
statement.type({ x: Type::NUMBER })

statement =
  Sequence.new(
    If.new(
      Variable.new(:b),
      Assign.new(:x, Number.new(6)),
      Assign.new(:x, Boolean.new(true))
    ),
    Sequence.new(
      If.new(
        Variable.new(:b),
        Assign.new(:y, Variable.new(:x)),
        Assign.new(:y, Number.new(1))
      ),
      Assign.new(:z, Add.new(Variable.new(:y), Number.new(1)))
    )
  )
statement.evaluate({ b: Boolean.new(true) })
statement.evaluate({ b: Boolean.new(false) })

statement.type({})
context = { b: Type::BOOLEAN, y: Type::NUMBER, z: Type::NUMBER }
statement.type(context)
statement.type(context.merge({ x: Type::NUMBER }))
statement.type(context.merge({ x: Type::BOOLEAN }))

# statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
# statement.type({ x: Type::NUMBER })
# statement.evaluate({})