# あいさつボット
class Greet
  def initialize(bot)
    bot.message(contains: /おは|こん|おや|堕|ぐっど|ただいま|てら|ちち/) do |event|
      next if event.channel.name != "一般"
      event.respond(greet)
    end
  end

  def greet
    a = "あかさたなはまやらわわわわわぱ".chars
    i = "いきしちちちちちにひみいりいぴ".chars
    a.sample + i.sample * 2 + "ー"
  end
end
