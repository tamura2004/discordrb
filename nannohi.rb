# 何の日ボット
class Nannohi
  NANNOHI_DATA = YAML.load(open("nanohi.yaml").read)

  def initialize(bot)
    bot.message(contains: /月|日|時|分|秒/) do |event|
      next if event.channel.name != "一般"
      event.respond say(NANNOHI_DATA, nil, "年", 1)
    end
  end

  def say(dic, x, y, n)
    a, b = ans = nil
    loop do
      a, b = ans = dic.keys.sample
      break if x.nil? && y.nil? && a == "。"
      break if x == a || y == b
    end

    while n > 0
      c = dic[[a, b]].keys.sample
      ans << c
      n -= 1 if c == "。"
      a, b = b, c
    end
    ans.shift if ans.first == "。"
    return ans.join
  end
end
