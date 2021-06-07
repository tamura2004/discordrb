module DummyBot
  class Listener
    attr_accessor :filter, :block

    def initialize(filter, block)
      @filter = filter
      @block = block
    end
  end

  class Bot
    attr_accessor :event, :listeners

    def initialize
      @event = Event.new
      @listeners = []
    end

    def message(contains: /./, &block)
      listeners << Listener.new(contains, block)
    end

    def run
      loop do
        event.content = gets.chomp
        event.msgs = []
        listeners.each do |listener|
          if event.content =~ listener.filter
            listener.block.call(event)
          end
        end
        event.msgs.each do |msg|
          puts msg
        end
      end
    end
  end

  class Author
    attr_accessor :display_name, :id

    def initialize
      @id = 1
      @display_name = "ななしさん"
    end
  end

  class Channel
    attr_accessor :name

    def initialize
      @name = "一般"
      # @name = "狂王の祭祀場"
    end
  end

  class Event
    attr_accessor :author, :content, :msgs, :channel

    def initialize
      @author = Author.new
      @msgs = []
      @channel = Channel.new
    end

    def <<(msg)
      msgs << msg
    end

    def respond(msg)
      msgs << msg
    end
  end
end
