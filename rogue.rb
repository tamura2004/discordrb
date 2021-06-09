module Rogue
  extend self

  def self.to_s
    "盗賊"
  end

  def yomi
    "と"
  end

  def find_treasure(players, monsters)
    if rand(6) < 3
      g = depth * rand(1..2)
      players.values.each do |pc|
        if pc.depth == depth
          @gp += g
        end
      end
      @depth += 1
      "パーティ全員が#{g}gp得た。奥に進む。"
    else
      dm = depth + rand(3)
      get_damage("罠だ！", dm)
    end
  end
end
