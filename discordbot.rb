# require "./monsters.rb"
# require "./items.rb"
# require "./rolldice.rb"

# def card(m)
#   "#{m[:size]}の#{m[:type]}#{m[:name]}が#{rand(100)}体現れた！"
# end

# def d(n, m)
#   Array.new(n) { rand(1..m) }
# end

require "discordrb"
require "yaml"
require "./game.rb"

TOKEN = ENV["DISCORD_BOT_TOKEN"]
TOKEN.freeze
bot = Discordrb::Bot.new token: TOKEN
g = Game.new

meros = YAML.load(open("meros.yaml").read)
rodger = YAML.load(open("rodger.yaml").read)

def say(dic, name, n)
  a, b = ans = [name, "は"]
  while n > 0
    c = dic[[a, b]].keys.sample
    ans << c
    n -= 1 if c == "。"
    a, b = b, c
  end
  return ans.join
end

bot.message do |event|
  id = event.author.id
  name = event.author.display_name
  pc = g.players[id]

  case event.content
  when /たたか|闘|戦/
    event << say(rodger, "ロジャー", 10)
  when /メロス|めろす|走/
    event << say(meros, "メロス", 5)
  when /new|create|はじめる|始める/
    if pc
      event << "#{pc.name}は迷宮を彷徨っている"
      event << pc.to_s
    else
      pc = g.add_player(id, name)
      event << "#{pc.name}が迷宮に入った"
      event << pc.to_s
    end
  else
    next if pc.nil?
    msgs = case event.content
      when /north|up|北|きた|上|うえ/
        g.move(pc, :up)
      when /west|left|西|にし|左|ひだり/
        g.move(pc, :left)
      when /east|right|東|ひがし|右|みぎ/
        g.move(pc, :right)
      when /sorth|down|南|みなみ|下|した/
        g.move(pc, :down)
      when /みる|見る|see/
        [g.see(pc)]
      when /すてーたす|ステータス/
        [pc.to_s]
      else
        []
      end
    msgs.each do |msg|
      event << msg
    end
  end
  nil
end

bot.run
