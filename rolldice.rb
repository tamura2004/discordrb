# ダイスボット
class RollDice
  def initialize(bot)
    bot.message(contains: /\:.*d.*\:/) do |event|
      event << rolldice(event.content)
    end
  end

  def rolldice(s)
    dice = Hash.new(0)
    s.scan(/\d*d\d+/).each do |code|
      n, m = code.split(/d/).map(&:to_i)
      dice[m] += n
    end

    code = dice.map { |k, v| "#{v}d#{k}" }.join("+")
    values = dice.map { |k, v| Array.new(v) { rand(1..k) } }

    "#{code} = [#{values.flatten.join("+")}] = #{values.flatten.sum}"
  end
end
