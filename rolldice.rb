# ダイスを振る
#
# ```
# rolldice("d20") # => 1d20 = [10] = 10
# rolldice("2d6") # => 2d6 = [2,5] = 7
# rolldice("2d6+5") # => 2d6 = [2,5] = 7
# ```
def rolldice(s)
  a = s.scan(/\d+|[^\d]+/)

  case a.size
  when 5
    op = a[3]
    n, _, m, _, k = a.map(&:to_i)
    case op
    when "+"
      ds = d(n, m)
      "#{s} = #{ds.inspect} + #{k} = #{ds.sum + k}"
    when "*"
      ds = Array.new(k) { d(n, k).sum }
      "#{s.sub(/\*/, "x")} = #{ds.inspect}"
    when "/"
      ds = d(n, m).sort.reverse.first(k).sum
      "#{s.sub(/\*/, "x")} = #{ds.inspect}"
    end
  when 3
    n, _, m = a.map(&:to_i)
    ds = d(n, m)
    "#{s} = #{ds.inspect} = #{ds.sum}"
  when 2
    _, m = a.map(&:to_i)
    n = 1
    ds = d(n, m)
    "#{s} = #{ds.inspect} = #{ds.sum}"
  else
    "まだ若いのよ"
  end
end
