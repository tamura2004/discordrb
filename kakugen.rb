# 格言ボット
class Kakugen
  KEIYOU = open("keiyoushi.txt").readlines(chomp: true)
  MEISHI = open("meishi.txt").readlines(chomp: true)

  def initialize(bot)
    bot.message(contains: /[るだす？]$/) do |event|
      next if event.channel.name != "一般"

      if rand < 0.5
        m = mei
        event << "#{kei}#{m}より#{kei}#{m}。"
      else
        k = kei
        event << "#{k}#{mei}より#{k}#{mei}。"
      end
    end
  end

  def kei
    KEIYOU.sample
  end

  def mei
    MEISHI.sample
  end
end
