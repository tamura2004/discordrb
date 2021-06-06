require "discordrb"
require "yaml"
require "./dummybot.rb"
require "./rolldice.rb"

TOKEN = ENV["DISCORD_BOT_TOKEN"]
TOKEN.freeze
bot = Discordrb::Bot.new token: TOKEN
# bot = DummyBot::Bot.new

meros = YAML.load(open("meros.yaml").read)
rodger = YAML.load(open("rodger.yaml").read)
nanohi = YAML.load(open("nanohi.yaml").read)

KEIYOU = open("keiyoushi.txt").readlines(chomp: true)
MEISHI = open("meishi.txt").readlines(chomp: true)

def kei
  KEIYOU.sample
end

def mei
  MEISHI.sample
end

def say(dic, x, y, n)
  a, b = ans = nil
  loop do
    a, b = ans = dic.keys.sample
    break if x.nil? && y.nil? && a == "。"
    break if x == a || y == b
  end

  while n > 0
    c = dic[[a, b]].keys.sample
    ans << c
    n -= 1 if c == "。"
    a, b = b, c
  end
  ans.shift if ans.first == "。"
  return ans.join
end

def greet
  a = "あかさたなはまやらわわわわわぱ".chars
  i = "いきしちちちちちにひみいりいぴ".chars
  a.sample + i.sample * 2 + "ー"
end

# 格言ボット
bot.message(contains: /[るだす？]$/) do |event|
  next if event.channel.name == "狂王の祭祀場" && event.channel.name == "ボットデバッグ用"

  if rand < 0.5
    k = kei
    event.respond("#{k}#{mei}より#{k}#{mei}。")
  else
    n = mei
    event.respond("#{kei}#{n}より#{kei}#{n}。")
  end
end

# あいさつボット
bot.message(contains: /おは|こん|おや|堕|ぐっど|ただいま|てら|ちち/) do |event|
  next if event.channel.name == "狂王の祭祀場" && event.channel.name == "ボットデバッグ用"
  event.respond(greet)
end

# ロジャーボット
bot.message(contains: /ろじゃー|だんじょん|ばーぐる/) do |event|
  next if event.channel.name == "狂王の祭祀場" && event.channel.name == "ボットデバッグ用"
  event.respond say(rodger, nil, nil, 3)
end

# メロスボット
bot.message(contains: /めろす|はしれ/) do |event|
  next if event.channel.name == "狂王の祭祀場" && event.channel.name == "ボットデバッグ用"
  event.respond say(meros, nil, nil, 3)
end

# 何の日ボット
bot.message(contains: /月|日|時|分|秒/) do |event|
  next if event.channel.name == "狂王の祭祀場" && event.channel.name == "ボットデバッグ用"
  event.respond say(nanohi, nil, "年", 1)
end

# ダイスボット
bot.message(contains: /\:.*d.*\:/) do |event|
  event.respond rolldice(event.content)
end

class Player
  attr_accessor :name, :race, :klass, :lv, :rpw, :pw, :rhp, :hp, :sp, :place, :gp, :exp

  def initialize(id)
    @id = id
    @lv = 1
    @gp = 10
    @exp = 0
  end

  def set_race(data)
    _, name, @rpw, @rhp = data
    @race = name
    @pw = lv + rpw
    @hp = lv + rhp
  end

  def set_klass(data)
    _, name, sp = data
    @klass = name
    @sp = sp
  end

  def levelup(e)
    @exp += e
    if @lv * 10 <= @exp
      @lv += 1
      @pw = lv + rpw
      @hp = lv + rhp
      "#{name}はレベルアップ！#{klass} #{to_s}"
    else
      "#{name}は#{e}経験値を得た。"
    end
  end

  def raisefromdead
    @pw = lv + rpw
    @hp = lv + rhp
    @gp -= lv
    gp >= 0
  end

  def to_s
    "#{name}(#{race}の#{klass}#{lv}lv #{pw}/#{hp} #{gp}gp #{exp}xp)"
  end
end

def d(n)
  rand(n) - (n / 2)
end

class Monster
  attr_accessor :name, :lv, :pw, :hp, :cdm
  RANK = ["", "チーフ", "リーダー", "キング", "エンペラー", "ゴッド"]
  NAME = %w(ゴブリン オーク バグベア スケルトン ミノタウルス ゴーレム ドラゴン)

  def initialize(base_lv)
    @lv = base_lv + rand(3)
    @name = NAME[lv % 7] + RANK[lv / 7]
    @pw = lv + d(3)
    @hp = lv + d(3)
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
monsters = []
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
      msg << "#{i + 1}.[#{menu.yomi}]#{menu.label}"
    end
    msg.join(",")
  end

  def select(s)
    case s
    when /[1-9]/
      i = s.to_i - 1
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

  case
  when pc.nil? || text =~ /りせっと/
    players[id] = Player.new(id)
    event << "#{auther}さんのキャラクターネームは？"
  when pc.name.nil?
    name = event.content
    pc.name = name
    event << "#{auther}さんのキャラクターは、#{name}さんです。種族は？"
  when pc.race.nil?
    race = races.find do |r|
      event.content =~ r[0]
    end || races[-1]
    pc.set_race(race)
    event << "#{pc.name}さんは#{pc.race}。クラスは？"
  when pc.klass.nil?
    klass = klasses.find do |c|
      event.content =~ c[0]
    end || klasses[-1]
    pc.set_klass(klass)
    pc.place = "リルガミン"
  when pc.place == "リルガミン"
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
    end
  when pc.place == "ダンジョン"
    case dungeon_menues.select(event.content)
    when /戦う/
      m = monsters[0]
      dm = pc.pw + d(5)
      event << "#{pc.name}は#{m.to_s}に攻撃。#{dm}ダメージ。"
      m.get_damage(dm, id)
      if m.dead?
        event << "#{m.to_s}は死んだ。"
        monsters.shift
        event << pc.levelup(m.lv)
      else
        dm = m.pw + d(5)
        event << "#{m.to_s}の反撃。#{dm}ダメージ。"
        pc.hp -= dm
        if pc.hp <= 0
          pc.place = "カント寺院"
        else
        end
      end
    when /探す/
      if rand(6) < 3
        g = rand(1..10) * pc.lv
        pc.gp += g
        event << "#{g}gp見つけた。"
      else
        event << "なにも見つからなかった。"
      end
    when /進む/
      event << "#{pc.name}は奥に進む。"
    when /逃げる/
      event << "#{pc.name}は逃げ出した。"
      pc.place = "リルガミン"
    end
  end

  next if pc.nil?

  case pc.place
  when "ダンジョン"
    monsters << Monster.new(pc.lv) if monsters.empty?
    event << monsters.first.to_s
    event << "#{pc}はどうする？#{dungeon_menues.message}"
  when "カント寺院"
    if pc.raisefromdead
      event << "#{pc.name}は死んだ。カント寺院で蘇生。#{pc.lv}gp寄付した。"
      event << pc.to_s
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
