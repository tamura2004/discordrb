class Menu
  attr_accessor :yomi, :to_s

  def initialize(yomi, to_s)
    @yomi = yomi
    @to_s = to_s
  end
end

class Menues
  attr_accessor :menues

  def initialize(menues)
    @menues = menues
  end

  def <<(menu)
    menues << menu
  end

  def message
    msg = []
    menues.each_with_index do |menu, i|
      msg << "#{i + 1}.[#{menu.yomi}]#{menu}"
    end
    msg.join(",")
  end

  def select(s)
    case s
    when /[1-9１-９]/
      i = s.tr("１-９", "1-9").to_i - 1
      menues[i] || menues.sample
    else
      m = menues.find { |m| s =~ /#{m.yomi}/ || s =~ /#{m}/ }
      m ||= menues.sample
      m
    end
  end
end
