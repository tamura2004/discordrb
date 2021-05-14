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

require "./rolldice.rb"
require "./monsters.rb"

TOKEN = ENV["DISCORD_BOT_TOKEN"]
TOKEN.freeze
bot = Discordrb::Bot.new token: TOKEN
g = Game.new

meros = YAML.load(open("meros.yaml").read)
rodger = YAML.load(open("rodger.yaml").read)
nanohi = YAML.load(open("nanohi.yaml").read)

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

def today(dic)
  a, b = ans = nil
  loop do
    a, b = ans = dic.keys.sample
    break if b == "年"
  end
  while ans.count("。") < 1
    ans << dic[[a, b]].keys.sample
    a, b = ans[-2, 2]
    break if ans.size > 100
  end
  return ans.join
end

def greet
  a = "あかさたなはまやらわわわわわぱ".chars
  i = "いきしちちちちちにひみいりいぴ".chars
  a.sample + i.sample * 2 + "ー"
end

bot.message(contains: /おは|こん|おや|堕|ぐっど|ただいま|てら/) do |event|
  if rand < 0.3
    event.respond(greet)
  else
    event.respond("わちちー")
  end
end

# ロジャーボット
bot.message(contains: /ろじゃー|だんじょん|ばーぐる/) do |event|
  event.respond say(rodger, "ロジャー", 10)
end

# メロスボット
bot.message(contains: /めろす|はしれ/) do |event|
  event.respond say(meros, "メロス", 5)
end

# 何の日ボット
bot.message(contains: /年|月|日|時|分|秒/) do |event|
  event.respond today(nanohi)
end

# ダイスボット
bot.message(contains: /\:.*d.*\:/) do |event|
  event.respond rolldice(event.content)
end

include Discordrb::Webhooks

# エンベッド練習
bot.message(contains: /monster/) do |event|
  mns = MONSTERS.sample
  pp mns
  event.channel.send_embed do |embed|
    embed.title = mns[:name]
    embed.description = mns[:size] + "の" + mns[:type] + "/" + mns[:alignment] + "/" + mns[:mv]
    embed.fields << EmbedField.new(name: "AC", value: mns[:ac], inline: true)
    embed.fields << EmbedField.new(name: "HP", value: mns[:maxHp], inline: true)
    embed.fields << EmbedField.new(name: "exp", value: mns[:exp], inline: true)
    %w(筋 敏 耐 知 判 魅).each_with_index do |label, i|
      embed.fields << EmbedField.new(name: label, value: mns[:ability][i], inline: true)
    end
    embed.fields << EmbedField.new(
      name: "属性",
      value: mns[:attributes].join("\n"),
    )
    embed.fields << EmbedField.new(
      name: "アクション",
      value: mns[:actions].join("\n"),
    )
    embed.fields << EmbedField.new(
      name: "特殊攻撃",
      value: mns[:specials].join("\n"),
    )
  end
end

bot.reaction_add do |event|
  pp event
end

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
