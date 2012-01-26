require 'blather/client/client'

module Roboter
  module Connectors
    class XMPP
      attr_reader :client

      def initialize(options = {})
        @client = Blather::Client.new

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

        @client.run
      end

      def stop
        @client.close
      end
    end
  end
end
