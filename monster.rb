class Monster
  attr_accessor :name, :lv, :pw, :hp, :cdm
  RANK = ["", "チーフ", "リーダー", "スピード", "キング", "クリムゾン", "エンペラー", "ゴッド", "アルティメット"]
  NAME = %w(スライム ゴブリン オーク ゾンビ バグベア スケルトン ミノタウルス マンティコア デーモン ゴーレム スフィンクス ドラゴン)

  def initialize(base_lv)
    @lv = base_lv
    @name = NAME[lv % (NAME.size)] + RANK[lv / (NAME.size)]
    @pw = lv
    @hp = lv
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
