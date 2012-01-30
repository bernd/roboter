require 'spec_helper'
require 'roboter/event_proxy'

describe Roboter::EventProxy do
  it "executes registered events" do
    proxy = described_class.new

    proxy.on(Roboter::Events::Connect) {|event| event.class.to_s }

    proxy.trigger(Roboter::Events::Connect.new).should == ['Roboter::Events::Connect']
  end
end
