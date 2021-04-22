require "natto"
require "yaml"

s = gets.chomp
m = Natto::MeCab.new

dic = Hash.new { |h, k| h[k] = Hash.new(0) }
m.enum_parse(s).map(&:surface).each_cons(4) do |a, b, c|
  dic[[a, b]][c] += 1
end

open("rodger.yaml", "w") do |fh|
  fh.write YAML.dump(dic)
end

a, b = ans = %w(ロジャー は)
while ans.count("。") < 7
  ans << dic[[a, b]].keys.sample
  a, b = ans[-2, 2]
  break if ans.size > 100
end
puts ans.join
