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
  end

  describe "#stop" do
    it "closes Blather::Client connection" do
      blather.should_receive(:close)
      xmpp.stop
    end
  end
end
