require 'blather/client/client'

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
      end

      def start
        @client.setup(@jid, @pass, @host, @port)

        # Remove initial error handler.
        @client.clear_handlers(:error)

        @client.register_handler(:disconnected, method(:handle_disconnect))

        @client.run

        EM.add_periodic_timer(@keepalive, method(:keepalive!))
      end

      def stop
        @client.close
      end

      def keepalive!
        @client.connected? ? @client.write(' ') : reconnect!
      rescue
        reconnect!
      end

      def reconnect!
        @client.run
      end

      private
      def handle_disconnect
        true # Return true to avoid stopping the event loop.
      end
    end
  end
end
