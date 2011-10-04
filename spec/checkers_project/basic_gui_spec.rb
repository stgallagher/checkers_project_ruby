require 'spec_helper'

describe BasicGui do
  
  before(:each) do
    @game = Game.new
  end 
  
  it "should print out an simple text display of the board" do
    @game.gui.render_board(@game.board).should == "R#R#R#R#\n" +
                                                  "#R#R#R#R\n" +
                                                  "R#R#R#R#\n" +
                                                  "# # # # \n" +
                                                  " # # # #\n" +
                                                  "#B#B#B#B\n" +
                                                  "B#B#B#B#\n" +
                                                  "#B#B#B#B\n"
  end
end

