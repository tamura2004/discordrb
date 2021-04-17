require "./dice"

MONSTERS = [
  {
    name: "ゴブリン",
    hp: "2d6",
    ac: 15,
    atk: 4,
    dmg: "1d6+2",
    exp: 50,
  },
]

# モンスター
class Monster
  @@id = 0
  attr_accessor :id, :name, :hp, :ac, :atk, :dmg, :exp, :y, :x

  def initialize(y, x)
    @y = y
    @x = x
    @id = @@id
    @@id += 1
    m = MONSTERS.sample
    @name = m[:name]
    @hp = r m[:hp]
    @ac = m[:ac]
    @atk = m[:atk]
    @dmg = m[:dmg]
    @exp = m[:exp]
  end
end
