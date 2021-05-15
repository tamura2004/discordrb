require "natto"
require "yaml"
require "pathname"
require "set"

m = Natto::MeCab.new
a = Set.new
b = Set.new

Pathname.new("src").find do |path|
  next unless path.file?
  next unless path.extname == ".txt"
  m.enum_parse(path.read).each do |n|
    if n.feature =~ /^名詞/
      next if n.surface.size <= 2
      next if n.surface =~ /^[ぁ？\.０-９0-9あ-んＡ-Ｚa-zA-Z]/

      a << n.surface
    end

    if n.feature =~ /^形容詞.*基本形/
      next if n.surface.size <= 1
      next if n.surface =~ /^[ぁ？\.０-９0-9あ-んＡ-Ｚa-zA-Z]/

      b << n.surface
    end
  end
end

open("meishi.txt", "w") do |fh|
  fh.write a.to_a.sort.join("\n")
end

open("keiyoushi.txt", "w") do |fh|
  fh.write b.to_a.sort.join("\n")
end

# x = a.to_a.sample
# y = b.to_a.sample
# z = a.to_a.sample
# w = b.to_a.sample

# puts "#{y}#{x}は#{w}#{z}と同じだ。"
# puts "#{y}#{x}は#{w}#{x}と大差ない。"
# puts "人間とは#{y}#{x}より#{w}#{z}を好む動物である。"
