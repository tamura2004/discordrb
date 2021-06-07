class Player
  attr_accessor :name, :race, :klass, :lv
  attr_accessor :rpw, :pw, :rhp, :hp, :sp, :gp, :exp
  attr_accessor :place, :depth

  RACES = [
    [/エルフ|える/, "エルフ", 2, 0],
    [/ドワーフ|どわ/, "ドワーフ", 0, 2],
    [/人間/, "人間", 1, 1],
  ]

  KLASSES = [
    [/そう|僧侶/, "僧侶", "治癒"],
    [/まほ|魔法/, "魔法使い", "火球"],
    [/とう|盗賊/, "盗賊", "毒罠"],
    [/せん|戦士/, "戦士", "剣盾"],
  ]

  def initialize(id)
    @id = id
    @lv = 1
    @gp = 10
    @exp = 0
    @place = "訓練場"
  end

  def making(event)
    author = event.author.display_name
    text = event.content

    case
    when name.nil?
      @name = text
      "#{author}さんのキャラクターは、#{name}さんです。種族は？"
    when race.nil?
      data = RACES.find do |r|
        event.content =~ r[0]
      end || RACES.sample
      set_race(data)
      "#{name}さんは#{data[1]}。クラスは？"
    when klass.nil?
      data = KLASSES.find do |c|
        event.content =~ c[0]
      end || KLASSES[-1]
      set_klass(data)
      @place = "リルガミン"
    end
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
    "#{name}(#{race}の#{klass} #{lv}lv #{pw}/#{hp} #{gp}gp #{exp}xp)"
  end
end
