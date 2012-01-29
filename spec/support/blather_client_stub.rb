# A simple stub for Blather::Client that can register and trigger
# events.
#
# The event trigger methods return an array with the return values of the
# callback invocations.
class BlatherClientStub
  def initialize
    @handler = {}
  end

  def trigger_ready
    Array(@handler[:ready]).map {|e| e.call }
  end

  def trigger_message(msg)
    Array(@handler[:message]).map {|e| e.call(msg) }
  end

  def trigger_error(err)
    Array(@handler[:error]).map {|e| e.call(err) }
  end

  def trigger_disconnect
    Array(@handler[:disconnected]).map {|e| e.call(err) }
  end

  def register_handler(event, &block)
    @handler[event.to_sym] ||= []
    @handler[event.to_sym] << block
  end

  # Swallow all remaining method calls on the object.
  def method_missing(*args); end
end
