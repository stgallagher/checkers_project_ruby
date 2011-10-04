require 'spec_helper'

describe Checker do
  before(:each) do
    @sample_checker = Checker.new(4 , 5, :red)
  end

  it "should have a location" do
    @sample_checker.x_pos.should == 4
    @sample_checker.y_pos.should == 5
  end

  it "should know its color" do
    @sample_checker.color.should == :red
  end

  it "should indicate if it is a king or not" do
    @sample_checker.isKing?.should == false
  end

  it"should be capable of becoming a king" do
    @sample_checker.make_king
    @sample_checker.isKing?.should == true
  end
end

