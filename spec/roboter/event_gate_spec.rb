require 'spec_helper'
require 'roboter/event_gate'

describe Roboter::EventGate do
  it "executes registered events" do
    gate = described_class.new

    gate.on(Roboter::Events::Connect) {|event| event.class.to_s }

    gate.trigger(Roboter::Events::Connect.new).should == ['Roboter::Events::Connect']
  end
end
