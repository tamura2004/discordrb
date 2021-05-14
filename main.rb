def cha
  ("あ".."ろ").to_a.sample
end

10.times do
  puts cha + cha * 2 + "ー"
end
