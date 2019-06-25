class TagRule < Struct.new(:first_character, :append_characters)
  def applies_to?(string)
    string.chars.first == first_character
  end

  def follow(string)
    string + append_characters
  end
end

class TagRulebook < Struct.new(:deletion_number, :rules)
  def next_string(string)
    rule_for(string).follow(string).slice(deletion_number..-1)
  end

  def rule_for(string)
    rules.detect { |r| r.applies_to?(string) }
  end

  def applies_to?(string)
    !rule_for(string).nil? && string.length >= deletion_number
  end
end

class TagSystem < Struct.new(:current_string, :rulebook)
  def step
    self.current_string = rulebook.next_string(current_string)
  end

  def run
    while rulebook.applies_to?(current_string)
      puts current_string
      step
    end

    puts current_string
  end
end

# 数を倍にする
# rulebook = TagRulebook.new(2, [TagRule.new('a', 'cc'), TagRule.new('b', 'dddd')])
# system = TagSystem.new('aabbbbbb', rulebook)
# system.run

# 数を半分にする
# rulebook = TagRulebook.new(2, [TagRule.new('a', 'cc'), TagRule.new('b', 'd')])
# system = TagSystem.new('aabbbbbbbbbbbb', rulebook)
# system.run

# 数をインクリメントする
# rulebook = TagRulebook.new(2, [TagRule.new('a', 'ccdd'), TagRule.new('b', 'dd')])
# system = TagSystem.new('aabbbb', rulebook)
# system.run

# 数を倍にしてから、インクリメントする
# rulebook = TagRulebook.new(2, [
#   TagRule.new('a', 'cc'), TagRule.new('b', 'dddd'), # 倍にする
#   TagRule.new('c', 'eeff'), TagRule.new('d', 'ff')  # インクリメントする
# ])
# system = TagSystem.new('aabbbb', rulebook)
# system.run

# 数が偶数か奇数かをテストする
# rulebook = TagRulebook.new(2, [
#   TagRule.new('a', 'cc'), TagRule.new('b', 'd'),
#   TagRule.new('c', 'eo'), TagRule.new('d', ''),
#   TagRule.new('e', 'e')
# ])
# 入力した数が偶数の場合
# system = TagSystem.new('aabbbbbbbb', rulebook)
# system.run
# 入力した数が奇数の場合
# system = TagSystem.new('aabbbbbbbbbb', rulebook)
# system.run