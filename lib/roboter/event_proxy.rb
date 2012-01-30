require 'roboter/events'

module Roboter
  class EventProxy
    def initialize
      @handler = Hash.new {|hash, key| hash[key] = []}
    end

    def on(type, &handler)
      @handler[type] << handler
    end

    def trigger(event)
      Array(@handler[event.class]).map do |handler|
        handler.call(event)
      end
    end
  end
end
