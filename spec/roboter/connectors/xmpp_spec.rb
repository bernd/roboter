require 'spec_helper'
require 'roboter/connectors/xmpp'

describe Roboter::Connectors::XMPP do
  let(:blather) { double('Blather::Client').as_null_object }

  let(:options) do
    {
      :jid => 'robo@example.com',
      :nick => 'robot',
      :pass => '1234',
      :host => 'xmpp.example.com',
      :port => 5222
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

    it "adds a disconnect handler that returns true" do
      blather.should_receive(:register_handler).with do |name, method|
        name == :disconnected and method.call == true
      end
      xmpp.start
    end

    it "starts the client connection" do
      blather.should_receive(:run)
      xmpp.start
    end

    it "sets up a keep-alive timer (5 sec)" do
      EM.should_receive(:add_periodic_timer).with do |number, method|
        number == 5 and method.name == :keepalive!
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

  describe "#keepalive!" do
    context "client connected" do
      it "will write an empty string to the client" do
        blather.stub(:connected?).and_return(true)
        blather.should_receive(:write).with(' ')
        xmpp.keepalive!
      end
    end

    context "client disconnected" do
      it "calls the reconnect handler" do
        blather.stub(:connected?).and_return(false)
        xmpp.should_receive(:reconnect!)
        xmpp.keepalive!
      end
    end

    context "with exception raised" do
      it "calls the reconnect handler" do
        blather.stub(:connected?).and_raise(RuntimeError)
        xmpp.should_receive(:reconnect!)
        xmpp.keepalive!
      end
    end
  end

  describe "#reconnect!" do
    it "calls run on the Blather::Client" do
      blather.should_receive(:run)
      xmpp.reconnect!
    end
  end
end
