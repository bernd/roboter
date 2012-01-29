require 'spec_helper'
require 'roboter/connectors/xmpp'
require 'blather_client_stub'

describe Roboter::Connectors::XMPP do
  let(:blather) { BlatherClientStub.new }
  let(:gate) { double('EventGate').as_null_object }

  let(:options) do
    {
      :jid => 'robo@example.com',
      :nick => 'robot',
      :pass => '1234',
      :host => 'xmpp.example.com',
      :port => 5222,
      :event_gate => gate
    }
  end

  let(:xmpp) { described_class.new(options) }


  before do
    Blather::Client.stub(:new).and_return(blather)
    EM.stub(:add_periodic_timer)
  end

  it "instantiates a Blather::Client object" do
    Blather::Client.should_receive(:new)
    described_class.new
  end

  describe "#start" do
    it "calls setup on the Blather::Client" do
      blather.should_receive(:setup).with(
        options[:jid], options[:pass], options[:host], options[:port]
      )
      xmpp.start
    end

    it "removes the initial error handler" do
      blather.should_receive(:clear_handlers).with(:error)
      xmpp.start
    end

    it "starts the client connection" do
      blather.should_receive(:run)
      xmpp.start
    end

    it "sets up a keep-alive timer (5 sec)" do
      EM.should_receive(:add_periodic_timer).with do |number, method|
        number == 5 and method.name == :keepalive
      end
      xmpp.start
    end
  end

  describe "#stop" do
    it "closes Blather::Client connection" do
      blather.should_receive(:close)
      xmpp.stop
    end
  end

  describe "#keepalive" do
    context "client connected" do
      it "will write an empty string to the client" do
        blather.stub(:connected?).and_return(true)
        blather.should_receive(:write).with(' ')
        xmpp.keepalive
      end
    end

    context "client disconnected" do
      it "calls the reconnect handler" do
        blather.stub(:connected?).and_return(false)
        xmpp.should_receive(:reconnect)
        xmpp.keepalive
      end
    end

    context "with exception raised" do
      it "calls the reconnect handler" do
        blather.stub(:connected?).and_raise(RuntimeError)
        xmpp.should_receive(:reconnect)
        xmpp.keepalive
      end
    end
  end

  describe "#reconnect" do
    it "calls run on the Blather::Client" do
      blather.should_receive(:run)
      xmpp.reconnect
    end
  end

  describe "connect event handling" do
    describe "ready event" do
      it "triggers a ready event on the gate" do
        connect = double('ConnectEvent')

        Roboter::Events::Connect.stub(:new).and_return(connect)
        gate.should_receive(:trigger).with(connect)

        xmpp.start
        blather.trigger_ready
      end
    end

    describe "message event" do
      it "triggers a message event on the gate" do
        message = double('MessageEvent')

        Roboter::Events::Message.stub(:new).with('Hallo').and_return(message)
        gate.should_receive(:trigger).with(message)

        xmpp.start
        blather.trigger_message('Hallo')
      end
    end

    describe "error event" do
      it "triggers an error event on the gate" do
        error = double('ErrorEvent')

        Roboter::Events::Error.stub(:new).with('ERROR').and_return(error)
        gate.should_receive(:trigger).with(error)

        xmpp.start
        blather.trigger_error('ERROR')
      end
    end

    describe "disconnect event" do
      it "triggers a disconnect event on the gate" do
        disconnect = double('DisconnectEvent')

        Roboter::Events::Disconnect.stub(:new).and_return(disconnect)
        gate.should_receive(:trigger).with(disconnect)

        xmpp.start
        blather.trigger_disconnect
      end

      it "executes a handler that returns true" do
        xmpp.start
        blather.trigger_disconnect.should == [true]
      end
    end
  end
end
