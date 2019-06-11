class LexicalAnalyzer < Struct.new(:string)
  GRAMMAR = [
    { token: 'i', pattern: /if/         }, # ifキーワード
    { token: 'e', pattern: /else/       }, # elseキーワード
    { token: 'w', pattern: /while/      }, # whileキーワード
    { token: 'd', pattern: /do-nothing/ }, # do-nothingキーワード
    { token: '(', pattern: /\(/)        }, # 開き括弧
    { token: ')', pattern: /\)/         }, # 閉じ括弧
    { token: '{', pattern: /\{/         }, # 開き中括弧
    { token: '}', pattern: /\}/         }, # 閉じ中括弧
    { token: ';', pattern: /;/          }, # セミコロン
    { token: '=', pattern: /=/          }, # 等号
    { token: '+', pattern: /\+/         }, # 足し算記号
    { token: '*', pattern: /\*/         }, # 掛け算記号
    { token: '<', pattern: /</          }, # 小なり記号
    { token: 'n', pattern: /[0-9]+/     }, # 数値
    { token: 'b', pattern: /true|false/ }, # ブール値
    { token: 'v', pattern: /[a-z]+/     }  # 変数名
  ]

  def analyze
    [].tap do |tokens|
      while more_tokens?
        tokens.push(next_token)
      end
    end
  end

  def more_tokens?
    !string.empty?
  end

  def next_token
    rule, match = rule_matching(string)
    self.string = string_after(match)
    rule[:token]
  end

  def rule_matching(string)
    matches = GRAMMAR.map { |rule| match_at_beginning(rule[:pattern], string) }
    rules_with_matches = GRAMMAR.zip(matches).reject { |rule, match| match.nil? }
    rule_with_longest_match(rules_with_matches)
  end

  def match_at_beginning(pattern, string)
    /\A#{pattern}/.match(string)
  end

  def rule_with_longest_match(rules_with_matches)
    rules_with_matches.max_by { |rule, match| match.to_s.length}
  end
end