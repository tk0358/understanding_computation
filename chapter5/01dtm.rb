class Tape < Struct.new(:left, :middle, :right, :blank)
  def inspect
    "#<Tape #{left.join}(#{middle})#{right.join}>"
  end

  def write(character)
    Tape.new(left, character, right, blank)
  end

  def move_head_left
    Tape.new(left[0..-2], left.last || blank, [middle] + right, blank)
  end

  def move_head_right
    Tape.new(left + [middle], right.first || blank, right.drop(1), blank)
  end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state, :character, :next_state,
                          :write_character, :direction)
  def applies_to?(configuration)
    state == configuration.state && character == configuration.tape.middle
  end

  def follow(configuration)
    TMConfiguration.new(next_state, next_tape(configuration))
  end

  def next_tape(configuration)
    written_tape = configuration.tape.write(write_character)

    case direction
    when :left
      written_tape.move_head_left
    when :right
      written_tape.move_head_right
    end
  end
end

class DTMRulebook < Struct.new(:rules)
  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end

  def applies_to?(configuration)
    !rule_for(configuration).nil?
  end
end

class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def step
    self.current_configuration = rulebook.next_configuration(current_configuration)
  end

  def stuck?
    !accepting? && !rulebook.applies_to?(current_configuration)
  end

  def run
    step until accepting? || stuck?
  end
end

tape = Tape.new(['1', '0', '1'], '1', [], '_')
tape.middle
tape
tape.move_head_left
tape.write('0')
tape.move_head_right
tape.move_head_right.write('0')

rule = TMRule.new(1, '0', 2, '1', :right)

rule.applies_to?(TMConfiguration.new(1, Tape.new([], '0', [], '_')))
rule.applies_to?(TMConfiguration.new(1, Tape.new([], '1', [], '_')))
rule.applies_to?(TMConfiguration.new(2, Tape.new([], '0', [], '_')))

rule.follow(TMConfiguration.new(1, Tape.new([], '0', [], '_')))

# 「２進数をインクリメントする」チューリングマシンのDTMRulebook
rulebook = DTMRulebook.new([
  TMRule.new(1, '0', 2, '1', :right),
  TMRule.new(1, '1', 1, '0', :left),
  TMRule.new(1, '_', 2, '1', :right),
  TMRule.new(2, '0', 2, '0', :right),
  TMRule.new(2, '1', 2, '1', :right),
  TMRule.new(2, '_', 3, '_', :left)
])

configuration = TMConfiguration.new(1, tape)
configuration = rulebook.next_configuration(configuration)
configuration = rulebook.next_configuration(configuration)
configuration = rulebook.next_configuration(configuration)

dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
dtm.current_configuration
dtm.accepting?
dtm.step; dtm.current_configuration
dtm.accepting?
dtm.run
dtm.current_configuration
dtm.accepting?

# 行き詰まり状態
tape = Tape.new(['1', '2', '1'], '1', [], '_')
dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
dtm.run
dtm.current_configuration
dtm.accepting?
dtm.stuck?


# 'aaabbbccc'のような文字列を認識するためのチューリングマシン
rulebook = DTMRulebook.new([
  # 状態１：aを探して右にスキャンする
  TMRule.new(1, 'X', 1, 'X', :right), # Xをスキップする
  TMRule.new(1, 'a', 2, 'X', :right), # aを消して、状態２に進む
  TMRule.new(1, '_', 6, '_', :left),  # 空白を見つけて、状態６（受理状態）に進む

  # 状態２：bを探して右にスキャンする
  TMRule.new(2, 'a', 2, 'a', :right), # aをスキップする
  TMRule.new(2, 'X', 2, 'X', :right), # Xをスキップする
  TMRule.new(2, 'b', 3, 'X', :right), # bを消して、状態３に進む

  # 状態３：ｃを探して右にスキャンする
  TMRule.new(3, 'b', 3, 'b', :right), # bをスキップする
  TMRule.new(3, 'X', 3, 'X', :right), # Xをスキップする
  TMRule.new(3, 'c', 4, 'X', :right), # cを消して、状態4に進む

  # 状態４：文字列の末尾を探して右にスキャンする
  TMRule.new(4, 'c', 4, 'c', :right), # cをスキップする
  TMRule.new(4, '_', 5, '_', :left),  # 空白を見つけて、状態５に進む

  # 状態５：文字列の先頭を探して左にスキャンする
  TMRule.new(5, 'a', 5, 'a', :left),  # aをスキップする
  TMRule.new(5, 'b', 5, 'b', :left),  # bをスキップする
  TMRule.new(5, 'c', 5, 'c', :left),  # cをスキップする
  TMRule.new(5, 'X', 5, 'X', :left),  # Xをスキップする
  TMRule.new(5, '_', 1, '_', :right)  # 空白を見つけて、状態１に進む
])
tape = Tape.new([], 'a', ['a', 'a', 'b', 'b', 'b', 'c', 'c', 'c'], '_')
dtm = DTM.new(TMConfiguration.new(1, tape), [6], rulebook)
10.times { dtm.step }; dtm.current_configuration
25.times { dtm.step }; dtm.current_configuration
dtm.run; dtm.current_configuration


# 文字列の先頭にある文字を末尾にコピーする（内部ストレージ）
rulebook = DTMRulebook.new([
  # 状態１：テープから先頭の文字を読む
  TMRule.new(1, 'a', 2, 'a', :right), # aを覚える
  TMRule.new(1, 'b', 3, 'b', :right), # bを覚える
  TMRule.new(1, 'c', 4, 'c', :right), # cを覚える

  # 状態２：文字列の末尾を探して右にスキャンする（aを覚えている）
  TMRule.new(2, 'a', 2, 'a', :right), # aをスキップする
  TMRule.new(2, 'b', 2, 'b', :right), # bをスキップする
  TMRule.new(2, 'c', 2, 'c', :right), # cをスキップする
  TMRule.new(2, '_', 5, 'a', :right), # 空白を見つけて、aを書く

  # 状態３：文字列の末尾を探して右にスキャンする（bを覚えている）
  TMRule.new(3, 'a', 3, 'a', :right), # aをスキップする
  TMRule.new(3, 'b', 3, 'b', :right), # bをスキップする
  TMRule.new(3, 'c', 3, 'c', :right), # cをスキップする
  TMRule.new(3, '_', 5, 'b', :right), # 空白を見つけて、bを書く

  # 状態４：文字列の末尾を探して右にスキャンする（cを覚えている）
  TMRule.new(4, 'a', 4, 'a', :right), # aをスキップする
  TMRule.new(4, 'b', 4, 'b', :right), # bをスキップする
  TMRule.new(4, 'c', 4, 'c', :right), # cをスキップする
  TMRule.new(4, '_', 5, 'c', :right)  # 空白を見つけて、cを書く
])

tape = Tape.new([], 'b', ['c', 'b', 'c', 'a'], '_')
dtm = DTM.new(TMConfiguration.new(1, tape), [5], rulebook)
dtm.run; dtm.current_configuration.tape


# 「数をインクリメントする」機械から「数に３を足す」機械を構築する
def increment_rules(start_state, return_state)
  incrementing = start_state
  finishing = Object.new
  finished = return_state

  [
    TMRule.new(incrementing, '0', finishing,    '1', :right),
    TMRule.new(incrementing, '1', incrementing, '0', :left),
    TMRule.new(incrementing, '_', finishing,    '1', :right),
    TMRule.new(finishing,    '0', finishing,    '0', :right),
    TMRule.new(finishing,    '1', finishing,    '1', :right),
    TMRule.new(finishing,    '_', finished,     '_', :left)
  ]
end

added_zero, added_one, added_two, added_three = 0, 1, 2, 3

rulebook = DTMRulebook.new(
  increment_rules(added_zero, added_one) +
  increment_rules(added_one, added_two) +
  increment_rules(added_two, added_three)
)
rulebook.rules.length
tape = Tape.new(['1', '0', '1'], '1', [], '_')
dtm = DTM.new(TMConfiguration.new(added_zero, tape), [added_three], rulebook)
dtm.run; dtm.current_configuration.tape