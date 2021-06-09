module Wizard
  extend self

  def self.to_s
    "魔法使い"
  end

  def yomi
    "ま"
  end

  def use_magic(players, monsters)
    if gp < lv
      "所持金が足りない。"
    else
      self.gp -= lv
      players.values.each do |pc|
        pc.pw += lv if pc.depth == depth
      end
      "パーティの攻撃力が上昇した。"
    end
  end
end
