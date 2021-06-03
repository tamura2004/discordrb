require "discordrb"
require "yaml"

TOKEN = ENV["DISCORD_BOT_TOKEN"]
TOKEN.freeze
bot = Discordrb::Bot.new token: TOKEN

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
  pp event.channel.name
  event.respond(greet)
end

# ロジャーボット
bot.message(contains: /ろじゃー|だんじょん|ばーぐる/) do |event|
  event.respond say(rodger, nil, nil, 3)
end

# メロスボット
bot.message(contains: /めろす|はしれ/) do |event|
  event.respond say(meros, nil, nil, 3)
end

# 何の日ボット
bot.message(contains: /月|日|時|分|秒/) do |event|
  event.respond say(nanohi, nil, "年", 1)
end

# ダイスボット
bot.message(contains: /\:.*d.*\:/) do |event|
  event.respond rolldice(event.content)
end

include Discordrb::Webhooks

bot.reaction_add do |event|
  pp event
end

class Player
  attr_accessor :name
  attr_accessor :race
  attr_accessor :klass
  attr_accessor :lv
  attr_accessor :rpw
  attr_accessor :pw
  attr_accessor :rhp
  attr_accessor :hp
  attr_accessor :sp

  def initialize(id)
    @id = id
    @lv = 1
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

  def levelup
    @lv += 1
    @pw = lv + rpw
    @hp = lv + rhp
    "#{name}はレベルアップ！#{klass} #{status}"
  end

  def to_s
    "#{name}:#{race}の#{klass}#{lv} #{status}"
  end

  def status
    "#{pw}/#{hp}"
  end
end

def d3
  rand(3) - 1
end

class Monster
  attr_accessor :name, :lv, :pw, :hp
  NAME = %w(ゴブリン オーク バグベア スケルトン ミノタウルス ゴーレム ドラゴン)

  def initialize
    @lv = rand(7)
    @name = NAME[lv]
    @pw = lv + d3
    @hp = lv + d3
  end

  def to_s
    "#{name} 攻#{pw}/防#{hp}"
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

bot.message do |event|
  next if event.channel.name != "狂王の祭祀場" && event.channel.name != "ボットデバッグ用"

  id = event.author.id
  auther = event.author.display_name
  pc = players[id]
  text = event.content

  case
  when pc.nil? || text =~ /りせっと/
    players[id] = Player.new(id)
    event.respond("#{auther}さんのキャラクターネームは？")
  when pc.name.nil?
    name = event.content
    pc.name = name
    event << "#{auther}さんのキャラクターは、#{name}さんです。"
    event << "種族は？"
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
    event << "#{pc.name}:#{pc.race}の#{pc.klass} 攻#{pc.pw}/防#{pc.hp} #{pc.sp}"
  when text =~ /たた/
    monsters << Monster.new if monsters.empty?
    m = monsters[0]
    dm = pc.pw + d3
    event << "#{pc.name}は#{m.to_s}に攻撃。#{dm}ダメージ。"
    m.hp -= dm
    if m.hp <= 0
      event << "#{m.to_s}は死んだ。"
      monsters.shift
      event << pc.levelup
    else
      dm = m.pw + d3
      event << "#{m.to_s}の反撃。#{dm}ダメージ。"
      pc.hp -= dm
      if pc.hp <= 0
        pc.pw += 1
        pc.hp = 1
        event << "#{pc.name}は地面に倒れソウルを失った。攻#{pc.pw}/防#{pc.hp}"
      else
      end
    end
  end
end

bot.run
