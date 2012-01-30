require 'blather/client/client'
require 'roboter/events'

module Roboter
  module Connectors
    class XMPP
      def initialize(options = {})
        @client = Blather::Client.new
        @keepalive = 5

        @jid = options[:jid]
        @nick = options[:nick]
        @pass = options[:pass]
        @host = options[:host]
        @port = options[:port]
        @event_proxy = options[:event_proxy]
      end

      def start
        @client.setup(@jid, @pass, @host, @port)

        # Remove initial error handler.
        @client.clear_handlers(:error)

        @client.register_handler(:ready) { handle_ready }
        @client.register_handler(:message) {|m| handle_message(m) }
        @client.register_handler(:error) {|e| handle_error(e) }
        @client.register_handler(:disconnected) { handle_disconnect }

        @client.run

        EM.add_periodic_timer(@keepalive, method(:keepalive))
      end

      def stop
        @client.close
      end

      def keepalive
        @client.write(' ') if @client.connected?
      end

      private
      def handle_ready
        @event_proxy.trigger(Events::Connect.new)
      end

      def handle_message(message)
        @event_proxy.trigger(Events::Message.new(message))
      end

      def handle_error(error)
        @event_proxy.trigger(Events::Error.new(error))
      end

      def handle_disconnect
        @event_proxy.trigger(Events::Disconnect.new)

        true # Return true to avoid stopping the event loop.
      end
    end
  end
end
