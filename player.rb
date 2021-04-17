require "./dice"

KLASS = [
  "戦士",
  "僧侶",
  "魔法使い",
  "盗賊",
]

class Player
  attr_accessor :id, :name, :klass, :level, :full, :hp, :ac, :atk, :dm, :exp, :gp, :y, :x

  def initialize(id, name, y, x)
    @id = id
    @name = name
    @y = y
    @x = x
    @klass = KLASS.sample
    @level = 1
    @full = r "1d4"
    @hp = full
    @ac = 16
    @atk = 4
    @dm = "1d8+3"
    @exp = 0
    @gp = r "4d4"
  end

  def to_s
    "#{name}:#{klass}/#{level},hp:#{hp}/#{full},AC:#{ac},atk:d20+#{atk},dm:#{dm},exp:#{exp},gp:#{gp}"
  end
end
