# 東、西、南、北、前、右、左、後
# 地図、マップ
# 見る
# 始める、やり直す
# 戦う
# 逃げる
# 飲む
# 使う
# ヒール
# ファイア
# 宝箱
# 扉
# 買う
# 売る
# 盗む

require "./game.rb"

g = Game.new
id = 1
name = "だいなも"
y = 1
x = 1

while s = gets
  case s
  when /はじめる|始める|new/
    if pc = g.players.values.find { |pc| pc.id == id }
      puts pc.to_s
    else
      pc = Player.new(id, name)
      y, x = g.add_player(pc)
      puts pc.to_s
    end
  when /n|u|北|きた|上|うえ/
    y, x, msg = g.move(y, x, -1, 0)
    puts msg
  when /w|l|西|にし|左|ひだり/
    y, x, msg = g.move(y, x, 0, -1)
    puts msg
  when /e|r|東|ひがし|右|みぎ/
    y, x, msg = g.move(y, x, 0, 1)
    puts msg
  when /s|d|南|みなみ|下|した/
    y, x, msg = g.move(y, x, 1, 0)
    puts msg
  when /みる|見る|see/
    puts g.see(y, x, id)
  end
end
