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

    it "should not allow a move that is off the board (to the right)" do
      not_moving_checker = @game.board[2][0]
      @game.move_validator(2, 0, 3, -1).should == "You cannot move off the board"
      @game.board[2][0].should equal(not_moving_checker)
    end
    
    it "should not allow a move that is off the board (to the left)" do
      not_moving_checker = @game.board[1][7]
      @game.move_validator(1, 7, 2, 8).should == "You cannot move off the board"
      @game.board[1][7].should equal(not_moving_checker)
    end

    it "should error if requested moving checker is not at location specified" do
      @game.move_validator(3, 1, 4, 2).should == "There is no checker to move in requested location"
      @game.board[3][1].should == nil
      @game.board[4][2].should == nil
    end

    it "should not allow non-diagonal moves" do
      not_moving_checker = @game.board[2][4]
      @game.move_validator(2, 4, 3, 4).should == "You can only move a checker diagonally"
      @game.move_validator(2, 4, 2, 5).should == "You can only move a checker diagonally"
      @game.board[2][4].should equal(not_moving_checker)
      @game.board[3][4].should == nil
      @game.board[2][5].should == nil
    end

    it "should not allow moves to occupied squares" do
      pending
    end

    it "should not allow backwards moves if checker is not a king" do
      pending
    end

    it "should allow backwards moves (if otherwise valid) if checker is a king" do
      pending
    end

    it "should allow jumps if there is an opposing checker in place and a vacant spot to land" do
      pending
    end

    it "should not allow jumps if there its over a players own checker" do
      pending
    end

    it "should not allow jumps if there is no vacant space to land" do
      pending
    end

    it "should force the player to jump if a jump is possible" do
      pending
    end 
  end
end
