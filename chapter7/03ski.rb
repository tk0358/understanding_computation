class SKISymbol < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    to_s
  end

  def combinator
    self
  end

  def arguments
    []
  end

  def callable?(*arguments)
    false
  end

  def reducible?
    false
  end

  def as_a_function_of(name)
    if self.name == name
      I
    else
      SKICall.new(K, self)
    end
  end
end

class SKICall < Struct.new(:left, :right)
  def to_s
    "#{left}[#{right}]"
  end

  def inspect
    to_s
  end

  def combinator
    left.combinator
  end

  def arguments
    left.arguments + [right]
  end

  def reducible?
    left.reducible? || right.reducible? || combinator.callable?(*arguments)
  end

  def reduce
    if left.reducible?
      SKICall.new(left.reduce, right)
    elsif right.reducible?
      SKICall.new(left, right.reduce)
    else
      combinator.call(*arguments)
    end
  end

  def as_a_function_of(name)
    left_function = left.as_a_function_of(name)
    right_function = right.as_a_function_of(name)

    SKICall.new(SKICall.new(S, left_function), right_function)
  end
end

class SKICombinator < SKISymbol
  def as_a_function_of(name)
    SKICall.new(K, self)
  end
end

S, K, I = [:S, :K, :I].map { |name| SKICombinator.new(name) }  

# S[a][b][c]をa[c][b[c]]に簡約する
def S.call(a, b, c)
  SKICall.new(SKICall.new(a, c), SKICall.new(b, c))
end

def S.callable?(*arguments)
  arguments.length == 3
end

# K[a][b]をaに簡約する
def K.call(a, b)
  a
end

def K.callable?(*arguments)
  arguments.length == 2
end

# I[a]をaに簡約する
def I.call(a)
  a
end


def I.callable?(*arguments)
  arguments.length == 1
end

x = SKISymbol.new(:x)
y, z = SKISymbol.new(:y), SKISymbol.new(:z)
S.call(x, y, z)

expression = SKICall.new(SKICall.new(SKICall.new(S, x), y), z)
combinator = expression.left.left.left
first_argument = expression.left.left.right
second_argument = expression.left.right
third_argument = expression.right
combinator.call(first_argument, second_argument, third_argument)

expression
combinator = expression.combinator
arguments = expression.arguments
combinator.call(*arguments)

expression = SKICall.new(SKICall.new(x, y), z)
combinator = expression.combinator
arguments = expression.arguments
# combinator.call(*arguments)

expression = SKICall.new(SKICall.new(S, x), y)
combinator = expression.combinator
arguments = expression.arguments
# combinator.call(*arguments)

expression = SKICall.new(SKICall.new(x, y), z)
expression.combinator.callable?(*expression.arguments)
expression = SKICall.new(SKICall.new(S, x), y)
expression.combinator.callable?(*expression.arguments)
expression = SKICall.new(SKICall.new(SKICall.new(S, x), y), z)
expression.combinator.callable?(*expression.arguments)

# swap = SKICall.new(SKICall.new(S, SKICall.new(K, SKICall.new(S, I))), K)
# expression = SKICall.new(SKICall.new(swap, x), y)
# while expression.reducible?
#   puts expression
#   expression = expression.reduce
# end; puts expression

original = SKICall.new(SKICall.new(S, K), I)
function = original.as_a_function_of(:x)

expression = SKICall.new(function, y)
# while expression.reducible?
#   puts expression
#   expression = expression.reduce
# end; puts expression

original = SKICall.new(SKICall.new(S, x), I)
function = original.as_a_function_of(:x)
expression = SKICall.new(function, y)
# while expression.reducible?
#   puts expression
#   expression = expression.reduce
# end; puts expression

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

  def callable?
    false
  end

  def reducible?
    false
  end

  def to_ski
    SKISymbol.new(name)
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

  def callable?
    true
  end

  def reducible?
    false
  end

  def to_ski
    body.to_ski.as_a_function_of(parameter)
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

  def callable?
    false
  end

  def reducible?
    left.reducible? || right.reducible? || left.callable?
  end

  def reduce
    if left.reducible?
      LCCall.new(left.reduce, right)
    elsif right.reducible?
      LCCall.new(left, right.reduce)
    else
      left.call(right)
    end
  end

  def to_ski
    SKICall.new(left.to_ski, right.to_ski)
  end
end

two =
  LCFunction.new(:p,
    LCFunction.new(:x,
      LCCall.new(LCVariable.new(:p), LCCall.new(LCVariable.new(:p), LCVariable.new(:x)))
    )
  )

inc, zero  = SKISymbol.new(:inc), SKISymbol.new(:zero)
expression = SKICall.new(SKICall.new(two.to_ski, inc), zero)
# while expression.reducible?
#   puts expression
#   expression = expression.reduce
# end; puts expression 

identity = SKICall.new(SKICall.new(S, K), K)
expression = SKICall.new(identity, x)
# while expression.reducible?
#   puts expression
#   expression = expression.reduce
# end; puts expression 