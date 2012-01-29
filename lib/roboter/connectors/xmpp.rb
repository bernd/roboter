require 'blather/client/client'
require 'roboter/events'

module Roboter
  module Connectors
    class XMPP
      attr_reader :client

      def initialize(options = {})
        @client = Blather::Client.new
        @keepalive = 5

        @jid = options[:jid]
        @nick = options[:nick]
        @pass = options[:pass]
        @host = options[:host]
        @port = options[:port]
        @event_gate = options[:event_gate]
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
        @client.connected? ? @client.write(' ') : reconnect
      rescue
        reconnect
      end

      def reconnect
        @client.run
      end

      private
      def handle_ready
        @event_gate.trigger(Events::Connect.new)
      end

      def handle_message(message)
        @event_gate.trigger(Events::Message.new(message))
      end

      def handle_error(error)
        @event_gate.trigger(Events::Error.new(error))
      end

      def handle_disconnect
        @event_gate.trigger(Events::Disconnect.new)

        true # Return true to avoid stopping the event loop.
      end
    end
  end
end
