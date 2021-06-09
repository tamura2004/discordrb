require "discordrb"
require "yaml"
require "./menu.rb"
require "./dummybot.rb"
require "./rolldice.rb"
require "./kakugen.rb"
require "./greet.rb"
require "./nannohi.rb"
require "./monster.rb"
require "./player.rb"

bot = nil
if ENV["DUMMY"] == "YES"
  bot = DummyBot::Bot.new
else
  TOKEN = ENV["DISCORD_BOT_TOKEN"]
  TOKEN.freeze
  bot = Discordrb::Bot.new token: TOKEN
end

RollDice.new(bot)
Greet.new(bot)
Nannohi.new(bot)

def d(n)
  rand(n) - (n / 2)
end

players = {}
monsters = Array.new(100) do |i|
  Monster.new(i)
end

town_menues = Menues.new([
  Menu.new("お", "王城"),
  Menu.new("ぶ", "武器屋"),
  Menu.new("ぼ", "防具屋"),
  Menu.new("だ", "ダンジョン"),
])

dungeon_menues = Menues.new([
  Menu.new("た", "戦う"),
  Menu.new("ま", "魔法"),
  Menu.new("さ", "探す"),
  Menu.new("す", "進む"),
  Menu.new("に", "逃げる"),
])

bot.message do |event|
  next if event.channel.name != "狂王の祭祀場" && event.channel.name != "ボットデバッグ用"

  id = event.author.id
  auther = event.author.display_name
  pc = players[id]
  text = event.content

  if pc.nil? || text =~ /りせっと/
    players[id] = Player.new(id, monsters)
    event << "#{auther}さんのキャラクターネームは？"
  else
    case pc.place
    when /訓練場/
      event << pc.making(event)
    when /リルガミン/
      case town_menues.select(event.content).to_s
      when /王城/
        event << pc.meet_king
      when /武器/
        event << pc.buy_weapon
      when /防具/
        event << pc.buy_armor
      when /ダンジョン/
        event << "#{pc.name}はダンジョンに入った"
        pc.place = "ダンジョン"
        pc.depth = 1
      end
    when /ダンジョン/
      case dungeon_menues.select(event.content).to_s
      when /戦う/
        m = monsters[pc.depth]
        if m.nil?
          event << "#{pc.name}は武器を振り回した・・・がモンスターはいない。奥に進む。"
          pc.depth += 1
        else
          dm = pc.pw + d(5)
          event << "#{pc.name}は#{m.to_s}に攻撃。#{dm}ダメージ。"
          m.get_damage(dm, id)
          if m.dead?
            event << "#{m.to_s}は死んだ。" + pc.levelup(m.lv) + "#{pc.name}は奥に進む。"
            monsters[pc.depth] = nil
            pc.depth += 1
          else
            dm = m.pw + d(5)
            event << pc.get_damage("#{m.to_s}の反撃。", dm)
          end
        end
      when /魔法/
        event << pc.use_magic(players, monsters)
      when /探す/
        event << pc.find_treasure(players, monsters)
      when /進む/
        event << pc.go_deep(monsters)
      when /逃げる/
        event << pc.escape
      end
    end
  end

  next if pc.nil?

  case pc.place
  when "ダンジョン"
    event << "#{pc}はどうする？#{dungeon_menues.message}"
  when "カント寺院"
    if pc.raisefromdead
      event << "#{pc.name}は死んだ。カント寺院で蘇生。#{pc.lv}gp寄付した。"
      pc.place = "リルガミン"
    else
      event << "#{pc.name}は死んだ。蘇生費用が無い。ロストしました。"
      players.delete(id)
    end
  end

  if pc.place == "リルガミン"
    event << "#{pc}はどうする？#{town_menues.message}"
  end
end

bot.run
