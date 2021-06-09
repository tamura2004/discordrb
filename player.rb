require "./menu.rb"
require "./fighter.rb"
require "./cleric.rb"
require "./wizard.rb"
require "./rogue.rb"
require "./human.rb"
require "./elf.rb"
require "./dwarf.rb"

class Player
  attr_accessor :name, :race, :klass, :lv
  attr_accessor :rpw, :pw, :rhp, :hp, :sp, :gp, :exp
  attr_accessor :place, :depth, :monsters

  RACES = Menues.new([
    Human,
    Elf,
    Dwarf,
  ])

  KLASSES = Menues.new([
    Fighter,
    Cleric,
    Wizard,
    Rogue,
  ])

  def initialize(id, monsters)
    @id = id
    @monsters = monsters
    @lv = 1
    @gp = 10
    @exp = 0
    @place = "訓練場"
    @depth = 0
  end

  def making(event)
    author = event.author.display_name
    text = event.content

    case
    when name.nil?
      @name = text
      "#{author}さんのキャラクターは、#{name}さんです。種族は？#{RACES.message}"
    when race.nil?
      set_race(event)
      "#{name}さんは#{race}。クラスは？#{KLASSES.message}"
    when klass.nil?
      set_klass(event)
      @place = "リルガミン"
    end
  end

  def set_race(event)
    @race = RACES.select(event.content)
    extend @race
    @pw = lv + rpw
    @hp = lv + rhp
  end

  def set_klass(event)
    @klass = KLASSES.select(event.content)
    extend @klass
  end

  def levelup(e)
    @exp += e
    if @lv * 10 <= @exp
      @lv += 1
      @pw = lv + rpw
      @hp = lv + rhp
      "#{name}はレベルアップ！#{to_s}"
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

  def use_magic(players, monsters)
    "#{klass}は魔法を使えない。"
  end

  def find_treasure(players, monsters)
    if monsters[depth]
      "モンスターが宝箱を守っている"
    elsif rand(6) < 3
      g = depth * rand(1..3)
      @gp += g
      @depth += 1
      "#{g}gp見つけた。奥に進む。"
    else
      dm = depth + rand(3)
      get_damage("罠だ！", dm)
    end
  end

  def go_deep(monsters)
    if monsters[depth]
      "モンスターが道を塞いでいる。"
    else
      depth.upto(99) do |d|
        if monsters[d]
          @depth = d
          break
        end
      end
      @depth = 0 if depth.nil?
      "#{name}は奥に進む。"
    end
  end

  def escape
    if rand(6) < 3
      @place = "リルガミン"
      @depth = 0
      "#{name}は逃げ出した。"
    else
      @depth += 1
      "逃げた方向はダンジョンの奥だった。" + get_damage("罠だ！", rand(3))
    end
  end

  def get_damage(msg, dm)
    @hp -= dm
    if hp <= 0
      @place = "カント寺院"
      @depth = 0
    end
    "#{msg}#{dm}ダメージ"
  end

  def meet_king
    if exp >= lv
      @gp += lv
      @exp -= lv
      "#{name}は王城に行った。王様「支度金である」"
    else
      "#{name}は王城に行った。王様「もっと経験を積め」"
    end
  end

  def buy_weapon
    if gp >= lv
      @gp -= lv
      @pw += lv
      "#{name}は武器屋に行った。折れた直剣を#{lv}gpで買った。"
    else
      "#{name}は武器屋に行ったが所持金が足りない。"
    end
  end

  def buy_armor
    if gp >= lv
      @gp -= lv
      @hp += lv
      "#{name}は防具屋に行った。汚れた鎧を#{lv}gpで買った。"
    else
      event << "#{name}は防具屋に行ったが所持金が足りない。"
    end
  end

  def place_name
    if place == "ダンジョン"
      "迷宮#{depth}層"
    else
      "街"
    end
  end

  def monster_name
    m = monsters[depth]
    if m.nil? || depth == 0
      "モンスターなし"
    else
      m.to_s
    end
  end

  def to_s
    "#{name}(#{race}の#{klass} #{lv}lv #{pw}/#{hp} #{gp}gp #{exp}xp #{place_name} #{monster_name})"
  end
end
