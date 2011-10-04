require 'spec_helper'

describe Game do
  
  describe "creating a board with checkers" do
    before(:each) do
      @game = Game.new
    end

    it "should have a board" do
      @game.board.should_not == nil
    end
    
    it "should be an 8 x 8 array" do
      @game.board.size.should == 8
      @game.board[3].size.should == 8
    end

    it "should take a checker" do
      checker = Checker.new(3, 3, :red)
      @game.place_checker_on_board(checker)
      @game.board[3][3].should equal(checker) 
    end

    it "should populate the board with checkers in the right positions" do
      @game.board[0][4].color.should == :red
      @game.board[1][3].color.should == :red
      @game.board[2][0].color.should == :red
      @game.board[5][7].color.should == :black
      @game.board[6][4].color.should == :black
      @game.board[7][3].color.should == :black
    end
  end

  describe "moving checkers" do
    
    before(:each) do
      @game = Game.new
    end

    it "move method should move a checker from one location to another" do
      #puts @game.gui.render_board(@game.board)
      #puts "\n\n"
      moving_checker = @game.board[2][2]
      @game.move(2, 2, 3, 1)
      @game.board[3][1].should equal(moving_checker)
      @game.board[2][2].should == nil
      #puts @game.gui.render_board(@game.board)
    end

    it "should not allow a move that is off the board" do
      pending
    end
  end
end
