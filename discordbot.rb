require "discordrb"
require "yaml"
require "./dummybot.rb"
require "./rolldice.rb"
require "./kakugen.rb"
require "./greet.rb"
require "./nannohi.rb"
require "./player.rb"

TOKEN = ENV["DISCORD_BOT_TOKEN"]
TOKEN.freeze

bot = nil
if ENV["DUMMY"] == "YES"
  bot = DummyBot::Bot.new
else
  bot = Discordrb::Bot.new token: TOKEN
end

RollDice.new(bot)
# Kakugen.new(bot)
Greet.new(bot)
Nannohi.new(bot)

def d(n)
  rand(n) - (n / 2)
end

class Monster
  attr_accessor :name, :lv, :pw, :hp, :cdm
  RANK = ["", "チーフ", "リーダー", "スピード", "キング", "クリムゾン", "エンペラー", "ゴッド", "アルティメット"]
  NAME = %w(スライム ゴブリン オーク ゾンビ バグベア スケルトン ミノタウルス マンティコア デーモン ゴーレム スフィンクス ドラゴン)

  def initialize(base_lv)
    @lv = base_lv
    @name = NAME[lv % (NAME.size)] + RANK[lv / (NAME.size)]
    @pw = lv
    @hp = lv
    @cdm = Hash.new(0)
  end

  def get_damage(dm, pc)
    cdm[pc] = dm if cdm[pc] < dm
  end

  def damage
    cdm.values.sum
  end

  def dead?
    hp <= damage
  end

  def to_s
    "#{name} 攻#{pw}/防#{hp - damage}"
  end
end

players = {}
monsters = Array.new(100) do |i|
  Monster.new(i)
end

races = [
  [/エルフ|える/, "エルフ", 2, 0],
  [/ドワーフ|どわ/, "ドワーフ", 0, 2],
  [/人間/, "人間", 1, 1],
]
klasses = [
  [/そう|僧侶/, "僧侶", "治癒"],
  [/まほ|魔法/, "魔法使い", "火球"],
  [/とう|盗賊/, "盗賊", "毒罠"],
  [/せん|戦士/, "戦士", "剣盾"],
]

def select_command(rs, a)
  rs.index { |r| r =~ a } || rand(rs.size)
end

class Menu
  attr_accessor :yomi, :label

  def initialize(yomi, label)
    @yomi = yomi
    @label = label
  end

  def to_s
    "[#{yomi}]#{label}"
  end
end

class Menues
  attr_accessor :menues

  def initialize(items)
    @menues = items.map do |item|
      Menu.new(*item)
    end
  end

  def <<(menu)
    menues << menu
  end

  def message
    msg = []
    menues.each_with_index do |menu, i|
      msg << "#{i + 1}.#{menu}"
    end
    msg.join(",")
  end

  def select(s)
    case s
    when /[1-9１-９]/
      i = s.tr("１-９","1-9").to_i - 1
      (menues[i] || menues.sample).label
    else
      m = menues.find { |m| s =~ /#{m.yomi}/ || s =~ /#{m.label}/ }
      m ||= menues.sample
      m.label
    end
  end
end

town_menues = Menues.new([
  ["お", "王城"],
  ["ぶ", "武器屋"],
  ["ぼ", "防具屋"],
  ["だ", "ダンジョン"],
])

dungeon_menues = Menues.new(
  [
    ["た", "戦う"],
    ["ま", "魔法"],
    ["さ", "探す"],
    ["す", "進む"],
    ["に", "逃げる"],
  ]
)

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
      case town_menues.select(event.content)
      when /王城/
        event << "#{pc.name}は王城に行った。王様「支度金である」"
        pc.gp += pc.lv
        pc.exp -= pc.lv
      when /武器/
        if pc.gp >= pc.lv
          event << "#{pc.name}は武器屋に行った。折れた直剣を#{pc.lv}gpで買った。"
          pc.gp -= pc.lv
          pc.pw += pc.lv
        else
          event << "#{pc.name}は武器屋に行ったが所持金が足りない。"
        end
      when /防具/
        if pc.gp >= pc.lv
          event << "#{pc.name}は防具屋に行った。汚れた鎧を#{pc.lv}gpで買った。"
          pc.gp -= pc.lv
          pc.hp += pc.lv
        else
          event << "#{pc.name}は防具屋に行ったが所持金が足りない。"
        end
      when /ダンジョン/
        event << "#{pc.name}はダンジョンに入った"
        pc.place = "ダンジョン"
        pc.depth = 1
      end
    when /ダンジョン/
      case dungeon_menues.select(event.content)
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
            event << "#{m.to_s}の反撃。#{dm}ダメージ。"
            pc.hp -= dm
            if pc.hp <= 0
              pc.place = "カント寺院"
              pc.depth = 0
            else
            end
          end
        end
      when /魔法/
        case pc.klass
        when /魔法使い/
          if pc.gp >= pc.lv
            players.values.each do |fr|
              if fr.depth == pc.depth
                fr.pw += pc.lv
              end
            end
            event << "味方全員の攻撃力が上昇した。"
            pc.gp -= pc.lv
          else
            event << "所持金が足りない"
          end
        when /僧侶/
          if pc.gp >= pc.lv
            players.values.each do |fr|
              if fr.depth == pc.depth
                fr.hp += pc.lv
              end
            end
            event << "味方全員の防御力が上昇した。"
            pc.gp -= pc.lv
          else
            event << "所持金が足りない"
          end
        else
          event << "#{pc.klass}は魔法を使えない"
        end
      when /探す/
        if monsters[pc.depth] && pc.klass != "盗賊"
          event << "モンスターが宝箱を守っている。"
        elsif rand(6) < 3 || pc.klass == "盗賊"
          g = rand(1..10) * pc.depth
          pc.gp += g
          event << "#{g}gp見つけた。奥に進む。"
        else
          event << "なにも見つからなかった。奥に進む。"
        end
        pc.depth += 1
      when /進む/
        if monsters[pc.depth]
          event << "モンスターが道を塞いでいる。"
        else
          event << "#{pc.name}は奥に進む。"
          pc.depth.upto(99) do |d|
            if monsters[d]
              pc.depth = d
              break
            end
          end
          pc.depth = 0 if pc.depth.nil?
        end
      when /逃げる/
        if pc.klass == "盗賊" || rand(6) < 3
          event << "#{pc.name}は逃げ出した。"
          pc.place = "リルガミン"
          pc.depth = 0
        else
          event << "逃げた方向はダンジョンの奥だった。"
          pc.depth += 1
        end
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
