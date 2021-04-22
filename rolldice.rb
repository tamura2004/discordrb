# ダイスを振る
#
# ```
# rolldice("d20") # => 1d20 = [10] = 10
# rolldice("2d6") # => 2d6 = [2,5] = 7
# rolldice("2d6+5") # => 2d6 = [2,5] = 7
# ```
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
