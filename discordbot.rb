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
require "./game.rb"

TOKEN = ENV["DISCORD_BOT_TOKEN"]
TOKEN.freeze
bot = Discordrb::Bot.new token: TOKEN
g = Game.new

bot.message do |event|
  id = event.author.id
  name = event.author.display_name
  pc = g.players[id]

  case event.content
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
