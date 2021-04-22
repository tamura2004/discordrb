require "./player.rb"
require "./monster.rb"
require "./treasure.rb"

# ゲームボード
class Game
  attr_accessor :map, :h, :w, :seen, :types
  attr_accessor :monsters, :treasures, :players

  def initialize
    @map = [
      "■■■■■■■■■■",
      "■　　　　扉　　　■",
      "■　　　　■　　　■",
      "■■■■■■■扉■■",
      "■　　　　　　　　■",
      "■■扉■■■■■■■",
      "■　　　　　　　　■",
      "■　　　　　　　　■",
      "■　　　　　　　　■",
      "■■■■■■■■■■",
    ]
    @h = @map.size
    @w = @map.first.size
    @seen = Array.new(h) { Array.new(w, false) }

    @monsters = {}
    7.times do
      add_monster
    end

    @treasures = {}
    2.times do
      y, x = empty_tile
      @treasures[[y, x]] = Treasure.new
    end

    @players = {}
  end

  def empty_tile
    100.times do
      y, x = rand(h), rand(w)
      break y, x if map[y][x] == "　"
    end
  end

  def add_player(id, name)
    y, x = empty_tile
    pc = Player.new(id, name, y, x)
    players[id] = pc
    return pc
  end

  def add_monster
    y, x = empty_tile
    m = Monster.new(y, x)
    monsters[m.id] = m
    return m
  end

  def monster?(y, x)
    monsters.values.find do |m|
      m.y == y && m.x == x
    end
  end

  def outside?(y, x)
    y < 0 || h <= y || x < 0 || w <= x
  end

  def each_neighbor(y, x)
    [-1, 0, 1].each do |dy|
      [-1, 0, 1].each do |dx|
        ny = y + dy
        nx = x + dx
        yield ny, nx
      end
    end
  end

  def each_cell
    h.times do |y|
      w.times do |x|
        yield y, x
      end
    end
  end

  def see(pc)
    y = pc.y
    x = pc.x
    each_neighbor(y, x) do |ny, nx|
      seen[ny][nx] = true
    end

    Array.new(h) { "□" * w }.tap do |ans|
      each_cell do |i, j|
        next unless seen[i][j]
        ans[i][j] = map[i][j]
        ans[i][j] = "宝" if @treasures.include?([i, j])
        ans[i][j] = "怪" if monster?(i, j)
        ans[i][j] = pc.name[0] if [i, j] == [y, x]
      end
    end.join("\n") + "\n"
  end

  DIR = {
    up: [-1, 0],
    down: [1, 0],
    left: [0, -1],
    right: [0, 1],
  }

  def move(pc, dir)
    ny = pc.y + DIR[dir][0]
    nx = pc.x + DIR[dir][1]

    msgs = []

    case
    when outside?(ny, nx)
      msgs << "マップ外です。"
    when map[ny][nx] == "■"
      msgs << "痛い。壁です。1ダメージ。"
      pc.hp -= 1
      if pc.hp <= 0
        players.delete(pc.id)
        msgs << "あなたは死んでしまった！"
      end
    when m = monster?(ny, nx)
      msgs << "#{m.name}に攻撃！"
      dmg = r pc.dm
      m.hp -= dmg
      msgs << "#{dmg}ダメージ"
      if m.hp <= 0
        msgs << "#{m.name}を倒した！"
        msgs << "#{m.exp}経験値を得た"
        monsters.delete(m.id)
      else
        msgs << "#{m.name}の反撃"
        dmg = r m.dm
        pc.hp -= dmg
        msgs << "#{dmg}ダメージ"
        if pc.hp <= 0
          msgs << "#{pc.name}は死んでしまった！"
          players.delete(pc.id)
        else
          msgs << "#{pc.name}:#{pc.hp}/#{pc.full}"
        end
      end
    when treasures.include?([ny, nx])
      pc.y = ny
      pc.x = nx
      gp = r "2d100"
      pc.gp += gp
      msgs << "#{pc.name}は宝箱を開けた。"
      msgs << "#{gp}ゴールドを得た。"
    when map[ny][nx] == "扉"
      pc.y = ny
      pc.x = nx
      msgs << "#{pc.name}は扉を開けた。"
      if rand < 0.7 && pc.klass != "盗賊"
        msgs << "爆発した。罠だ！"
        dm = r "2d6"
        msgs << "#{dm}ダメージ"
        pc.hp -= dm
        if pc.hp <= 0
          players.delete(pc.id)
          msgs << "あなたは死んでしまった！"
        end
      else
        msgs << "扉に爆発の罠が！"
        msgs << "盗賊のあなたは罠を解除した"
      end
    when map[ny][nx] == "　"
      pc.y = ny
      pc.x = nx
      msgs << "#{pc.name}は移動しました。"
    else
      msgs << "#{map[ny][nx]}がよくわかりません"
    end

    msgs
  end
end
