module Cleric
  extend self

  def self.to_s
    "僧侶"
  end

  def yomi
    "そ"
  end

  def use_magic(players, monsters)
    if gp < lv
      "所持金が足りない。"
    else
      self.gp -= lv
      players.values.each do |pc|
        pc.hp += lv if pc.depth == depth
      end
      "パーティの防御力が上昇した。"
    end
  end
end
