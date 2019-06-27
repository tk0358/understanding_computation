class Sign < Struct.new(:name)
  NEGATIVE, ZERO, POSITIVE = [:negative, :zero, :positive].map { |name| new(name) }
  UNKNOWN = new(:unknown)

  def inspect
    "#<Sign #{name}>"
  end

  def *(other_sign)
    if [self, other_sign].include?(ZERO)
      ZERO
    elsif [self, other_sign].include?(UNKNOWN)
      UNKNOWN
    elsif self == other_sign
      POSITIVE
    else
      NEGATIVE
    end
  end

  def +(other_sign)
    if self == other_sign || other_sign == ZERO
      self
    elsif self == ZERO
      other_sign
    else
      UNKNOWN
    end
  end

  def <=(other_sign)
    self == other_sign || other_sign == UNKNOWN
  end
end

class Numeric
  def sign
    if self < 0
      Sign::NEGATIVE
    elsif zero?
      Sign::ZERO
    else
      Sign::POSITIVE
    end
  end
end

def calculate(x, y, z)
  (x * y) * (x * z)
end

def sum_of_squares(x, y)
  (x * x) + (y * y)
end

Sign::POSITIVE + Sign::POSITIVE
Sign::NEGATIVE + Sign::ZERO
Sign::NEGATIVE + Sign::POSITIVE

Sign::POSITIVE + Sign::UNKNOWN
Sign::UNKNOWN + Sign::ZERO
Sign::POSITIVE + Sign::NEGATIVE + Sign::NEGATIVE

(Sign::POSITIVE + Sign::NEGATIVE) * Sign::ZERO + Sign::POSITIVE

(10 + 3).sign == (10.sign + 3.sign)
(-5 + 0).sign == (-5.sign + 0.sign)
(6 + -9).sign == (6.sign + -9.sign)
(6 + -9).sign
6.sign + -9.sign

Sign::POSITIVE <= Sign::POSITIVE
Sign::POSITIVE <= Sign::UNKNOWN
Sign::POSITIVE <= Sign::NEGATIVE

(6 * -9).sign <= (6.sign * -9.sign)
(-5 + 0).sign <= (-5.sign + 0.sign)
(6 + -9).sign <= (6.sign + -9.sign)

inputs = Sign::NEGATIVE, Sign::ZERO, Sign::NEGATIVE
outputs = inputs.product(inputs).map { |x, y| sum_of_squares(x, y) }
outputs.uniq