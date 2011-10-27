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
      @game.red_checkers_left.should == 13 
    end

    it "should populate the board with checkers in the right positions" do
      @game.board[0][4].color.should == :red
      @game.board[1][3].color.should == :red
      @game.board[2][0].color.should == :red
      @game.board[5][7].color.should == :black
      @game.board[6][4].color.should == :black
      @game.board[7][3].color.should == :black
    end

    it "should have maintain a collection of checkers for each color" do
      @game.red_checkers_left.should   == 12
      @game.black_checkers_left.should == 12
    end
  end

  describe "playing game" do  
    before(:each) do
      @game = Game.new
    end
    
    it "starts with a welcome message" do
      @game.intro.should == "Welcome to Checkers!"
    end
    
    it "requests a move from the current player" do
      @game.move_request.should == "RED make move(x1, y1, x2, y2): "
    end
    
    it "translates a move request string into an array of coordinates" do
      player_input = "3, 3, 5, 5"
      translated_array = @game.translate_move_request_to_coordinates(player_input)
      translated_array.should == [3, 3, 5, 5]
    end    

    it "should switch player as necessary" do
      @game.current_player = :red
      @game.switch_player.should == :black
    end

    it "should ask how many players are playing and store the value" do
      pending
    end

    it "should end the game when all the checkers of one color are removed" do
      @game.create_test_board
      lone_red_checker = Checker.new(2, 2, :red)
      lone_black_checker = Checker.new(5, 5, :black)
      @game.place_checker_on_board(lone_red_checker) 
      @game.place_checker_on_board(lone_black_checker)
      @game.game_over?.should == false
      @game.board[2][2] = nil
      @game.game_over?.should == true 
    end

    it "should display appropriate game ending message telling who won" do
      @game.create_test_board
      lone_black_checker = Checker.new(5, 5, :black)
      @game.place_checker_on_board(lone_black_checker)
      @game.display_game_ending_message.should == "\n\nCongratulations, black, You have won!!!"
    end
  end

  describe "moving checkers" do
    
    before(:each) do
      @game = Game.new
    end

    it "move method should move a checker from one location to another (for red)" do
      @game.current_player = :red
      moving_checker = @game.board[2][2]
      @game.configure_coordinates([2, 2, 3, 1])
      @game.move
      @game.board[3][1].should equal(moving_checker)
      @game.board[2][2].should == nil
    end
    
    it "move method should move a checker from one location to another (for red)" do
      @game.current_player = :black
      moving_checker = @game.board[2][2]
      @game.configure_coordinates([2, 2, 3, 1])
      @game.move
      @game.board[3][1].should equal(moving_checker)
      @game.board[2][2].should == nil
    end
    
    it "should not allow a move that is off the board (to the right)" do
      @game.current_player = :red
      not_moving_checker = @game.board[2][0]
      @game.configure_coordinates([2, 0, 3, -1])
      @game.move_validator.should == "You cannot move off the board"
      @game.board[2][0].should equal(not_moving_checker)
    end
    
    it "should not allow a move that is off the board (to the left)" do
      @game.current_player = :red
      not_moving_checker = @game.board[1][7]
      @game.configure_coordinates([1, 7, 2, 8])
      @game.move_validator.should == "You cannot move off the board"
      @game.board[1][7].should equal(not_moving_checker)
    end

    it "should error if requested moving checker is not at location specified (for red)" do
      @game.current_player = :red
      @game.configure_coordinates([3, 1, 4, 2])
      @game.move_validator.should == "There is no checker to move in requested location"
      @game.board[3][1].should == nil
      @game.board[4][2].should == nil
    end
    
    it "should error if requested moving checker is not at location specified (for black)" do
      @game.current_player = :black
      @game.configure_coordinates([4, 6, 3, 7])
      @game.move_validator.should == "There is no checker to move in requested location"
    end
    
    it "should error if requested moving checker is not current player's color (for red)" do
      @game.current_player = :red
      @game.configure_coordinates([5, 5, 4, 4])
      @game.move_validator.should == "You cannot move an opponents checker"
    end
    
    it "should error if requested moving checker is not current player's color (for black)" do
      @game.current_player = :black
      @game.configure_coordinates([2, 0, 3, 1])
      @game.move_validator.should == "You cannot move an opponents checker"
    end
    
    it "should error if requested move is a jump of an empty space(for red)" do
      @game.current_player = :red
      @game.configure_coordinates([2, 2, 4, 4])
      @game.move_validator.should == "You cannot jump an empty space"
    end
    
    it "should error if requested move is a jump of an empty space(for black)" do
      @game.current_player = :black
      @game.configure_coordinates([5, 5, 3, 3])
      @game.move_validator.should == "You cannot jump an empty space"
    end
    
    it "should error if requested move is greater than one space and not a jump (for red)" do
      @game.current_player = :red
      @game.create_test_board
      red_checker = Checker.new(2, 2, :red)
      @game.place_checker_on_board(red_checker)
      @game.configure_coordinates([2, 2, 5, 5])
      @game.move_validator.should == "You cannot move more than one space if not jumping"
    end
    
    it "should error if requested move is greater than one space and not a jump (for black)" do
      @game.current_player = :black
      @game.create_test_board
      black_checker = Checker.new(5, 5, :black)
      @game.place_checker_on_board(black_checker)
      @game.configure_coordinates([5, 5, 2, 2])
      @game.move_validator.should == "You cannot move more than one space if not jumping"
    end

    it "should not allow non-diagonal moves" do
      not_moving_checker = @game.board[2][4]
      @game.configure_coordinates([2, 4, 3, 4])
      @game.move_validator.should == "You can only move a checker diagonally"
      @game.configure_coordinates([2, 4, 2, 5])
      @game.move_validator.should == "You can only move a checker diagonally"
      @game.board[2][4].should equal(not_moving_checker)
      @game.board[3][4].should == nil
      @game.board[2][5].should == nil
    end

    it "should not allow moves to occupied squares" do
      moving_checker = @game.board[1][1]
      stationary_checker = @game.board[2][2]
      @game.configure_coordinates([1, 1, 2, 2])
      @game.move_validator.should == "You cannot move to an occupied square"
      @game.board[1][1].should equal(moving_checker)
      @game.board[2][2].should equal(stationary_checker)
    end

    it "should not allow backwards moves if checker is not a king" do
      @game.create_test_board
      non_king_checker = Checker.new(3, 3, :red)
      @game.place_checker_on_board(non_king_checker)
      @game.configure_coordinates([3, 3, 2, 2])
      @game.move_validator.should == "A non-king checker cannot move backwards" 
    end

    it "should allow backwards moves (if otherwise valid) if checker is a king" do
      @game.create_test_board
      king_checker = Checker.new(3, 3, :red)
      king_checker.make_king
      @game.place_checker_on_board(king_checker)
      @game.configure_coordinates([3, 3, 2, 2])
      @game.move_validator.should == nil
      @game.board[2][2].should equal(king_checker)
    end

    it "should designate a checker a king when it reaches the back row (for red)" do
      @game.create_test_board
      transforming_to_king_checker = Checker.new(6, 2, :red)
      @game.place_checker_on_board(transforming_to_king_checker)
      transforming_to_king_checker.isKing?.should == false
      @game.configure_coordinates([6, 2, 7, 1])
      @game.move_validator
      transforming_to_king_checker.isKing?.should == true
    end
    
    it "should designate a checker a king when it reaches the back row (for black)" do
    
    end
  end
  
  describe "jumping checkers" do

    before(:each) do
      @game = Game.new
      @game.board = @game.create_test_board
    end
   
    it "shoud have a test helper method that sets x and y test values for test" do
     @game.set_scan_values(3, 5)
     @game.x_scan.should == 3
     @game.y_scan.should == 5
    end

    it "should scan adjacent positions and tell what they contain (for red)" do
      reference_checker = Checker.new(4, 4, :red)
      upper_left_checker = Checker.new(5, 5, :black)
      lower_right_checker = Checker.new(3, 3, :black)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(lower_right_checker)
      @game.set_scan_values(4, 4)
      adjacent_positions = @game.adjacent_positions
      adjacent_positions["upper_left"].class.should  == Checker
      adjacent_positions["upper_right"].should       == nil
      adjacent_positions["lower_left"].should        == nil
      adjacent_positions["lower_right"].class.should == Checker
    end
    
    it "should scan adjacent positions and tell what they contain (for black)" do
      @game.current_player = :black
      reference_checker = Checker.new(4, 4, :black)
      upper_left_checker = Checker.new(3, 3, :red)
      lower_right_checker = Checker.new(5, 5, :red)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(lower_right_checker)
      @game.set_scan_values(4, 4)
      adjacent_positions = @game.adjacent_positions
      adjacent_positions["upper_left"].class.should  == Checker
      adjacent_positions["upper_right"].should       == nil
      adjacent_positions["lower_left"].should        == nil
      adjacent_positions["lower_right"].class.should == Checker
    end
    
    it "should tell where there are adjacent opposing checkers (for red)" do
      reference_checker = Checker.new(4, 4, :red)
      upper_left_checker = Checker.new(5, 5, :black)
      lower_right_checker = Checker.new(3, 3, :black)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(lower_right_checker)
      @game.set_scan_values(4, 4)
      opposing_checkers = @game.opposing_checker_adjacent
      opposing_checkers["upper_left"].should  == true 
      opposing_checkers["upper_right"].should == nil
      opposing_checkers["lower_left"].should  == nil
      opposing_checkers["lower_right"].should == true
    end
    
    it "should tell where there are adjacent opposing checkers (for black)" do
      @game.current_player = :black
      reference_checker = Checker.new(4, 4, :black)
      upper_left_checker = Checker.new(3, 3, :red)
      lower_right_checker = Checker.new(5, 5, :red)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(lower_right_checker)
      @game.set_scan_values(4, 4)
      opposing_checkers = @game.opposing_checker_adjacent
      opposing_checkers["upper_left"].should  == true 
      opposing_checkers["upper_right"].should == nil
      opposing_checkers["lower_left"].should  == nil
      opposing_checkers["lower_right"].should == true
    end
    
    it "should give indicate where a jump is available, relative to a single checker (for red)" do
      @game.current_player = :red
      reference_checker = Checker.new(4, 4, :red)
      upper_left_checker = Checker.new(5, 5, :black)
      upper_right_checker = Checker.new(5, 3, :black)
      blocking_upper_right_jump_checker = Checker.new(6, 2, :black)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(upper_right_checker)
      @game.place_checker_on_board(blocking_upper_right_jump_checker)
      @game.set_scan_values(4, 4)
      available_jumps = @game.jump_locations
      available_jumps["upper_left"].should == true
      available_jumps["upper_right"].should == false
      available_jumps["lower_left"].should == false
      available_jumps["lower_right"].should == false
    end
    
    it "should give indicate where a jump is available, relative to a single checker (for black)" do
      @game.current_player = :black
      reference_checker = Checker.new(4, 4, :black)
      upper_left_checker = Checker.new(3, 3, :red)
      upper_right_checker = Checker.new(3, 5, :red)
      blocking_upper_right_jump_checker = Checker.new(2, 6, :red)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(upper_right_checker)
      @game.place_checker_on_board(blocking_upper_right_jump_checker)
      @game.set_scan_values(4, 4)
      available_jumps = @game.jump_locations
      available_jumps["upper_left"].should  == true
      available_jumps["upper_right"].should == false
      available_jumps["lower_left"].should  == false
      available_jumps["lower_right"].should == false
    end
   
    it "should indicate a backwards jump only if checker is a king, relative to a single checker (for red)" do
      @game.current_player = :red
      reference_checker = Checker.new(4, 4, :red)
      upper_left_checker = Checker.new(5, 5, :black)
      lower_right_checker = Checker.new(3, 3, :black)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(lower_right_checker)
      @game.set_scan_values(4, 4)
      available_jumps = @game.jump_locations
      available_jumps["upper_left"].should == true
      available_jumps["upper_right"].should == false
      available_jumps["lower_left"].should == false
      available_jumps["lower_right"].should == false
      
      reference_checker.make_king
      available_jumps = @game.jump_locations
      available_jumps["upper_left"].should == true
      available_jumps["upper_right"].should == false
      available_jumps["lower_left"].should == false
      available_jumps["lower_right"].should == true
    end 
    
    it "should indicate a backwards jump only if checker is a king, relative to a single checker (for black)" do
      @game.current_player = :black
      reference_checker = Checker.new(4, 4, :black)
      upper_left_checker = Checker.new(3, 3, :red)
      lower_right_checker = Checker.new(5, 5, :red)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(lower_right_checker)
      @game.set_scan_values(4, 4)
      available_jumps = @game.jump_locations
      available_jumps["upper_left"].should == true
      available_jumps["upper_right"].should == false
      available_jumps["lower_left"].should == false
      available_jumps["lower_right"].should == false
      
      reference_checker.make_king
      @game.set_scan_values(4, 4)
      available_jumps = @game.jump_locations
      available_jumps["upper_left"].should == true
      available_jumps["upper_right"].should == false
      available_jumps["lower_left"].should == false
      available_jumps["lower_right"].should == true
    end
    
    it "should produce a set of location coordinates for potential jump locations (for red)" do
      @game.current_player = :red
      reference_checker = Checker.new(4, 4, :red)
      upper_left_checker = Checker.new(5, 5, :black)
      upper_right_checker = Checker.new(5, 3, :black)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(upper_right_checker)
      @game.set_scan_values(4, 4)
      @game.jump_locations_coordinates.should == ([[6, 6], [6, 2]])
    end 
    
    it "jump locations should not include jumps that are blocked (for red)" do
      @game.current_player = :red
      reference_checker = Checker.new(4, 4, :red)
      upper_left_checker = Checker.new(5, 5, :black)
      upper_right_checker = Checker.new(5, 3, :black)
      blocking_upper_right_jump_checker = Checker.new(6, 2, :black)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(upper_right_checker)
      @game.place_checker_on_board(blocking_upper_right_jump_checker)
      @game.set_scan_values(4, 4)
      @game.jump_locations_coordinates.should == ([[6, 6]])
    end
    
    it "should produce a set of location coordinates for potential jump locations (for black)" do
      @game.current_player = :black
      reference_checker = Checker.new(4, 4, :black)
      upper_left_checker = Checker.new(3, 3, :red)
      upper_right_checker = Checker.new(3, 5, :red)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(upper_right_checker)
      @game.set_scan_values(4, 4)
      @game.jump_locations_coordinates.should == ([[2, 2], [2, 6]])
    end 
    
    it "jump locations should not include jumps that are blocked (for black)" do
      @game.current_player = :black
      reference_checker = Checker.new(4, 4, :black)
      upper_left_checker = Checker.new(3, 3, :red)
      upper_right_checker = Checker.new(3, 5, :red)
      blocking_upper_right_jump_checker = Checker.new(2, 6, :red)
      @game.place_checker_on_board(reference_checker)
      @game.place_checker_on_board(upper_left_checker)
      @game.place_checker_on_board(upper_right_checker)
      @game.place_checker_on_board(blocking_upper_right_jump_checker)
      @game.set_scan_values(4, 4)
      @game.jump_locations_coordinates.should == ([[2, 2]])
    end
    
    it "should survey all the checkers to see and build a list of possible jumps (for red)" do
      @game.current_player = :red
      red_checker1 = Checker.new(1, 1, :red)
      red_checker2 = Checker.new(3, 3, :red)  
      red_checker3 = Checker.new(1, 7, :red)  
      black_checker1 = Checker.new(4, 2, :black)
      black_checker2 = Checker.new(4, 4, :black) 
      black_checker3 = Checker.new(2, 6, :black) 
      black_checker4 = Checker.new(6, 6, :black) 
      @game.place_checker_on_board(red_checker1)
      @game.place_checker_on_board(red_checker2)
      @game.place_checker_on_board(red_checker3)
      @game.place_checker_on_board(black_checker1) 
      @game.place_checker_on_board(black_checker2)
      @game.place_checker_on_board(black_checker3)
      @game.place_checker_on_board(black_checker4)
      @game.generate_jump_locations_coordinates_list.should == [ 3, 5, 5, 5, 5, 1]
    end
    
    it "should survey all the checkers to see and build a list of possible jumps (for black)" do
      @game.current_player = :black
      red_checker1 = Checker.new(1, 1, :red)
      red_checker2 = Checker.new(3, 3, :red)  
      red_checker3 = Checker.new(1, 7, :red)  
      black_checker1 = Checker.new(4, 2, :black)
      black_checker2 = Checker.new(4, 4, :black) 
      black_checker3 = Checker.new(2, 6, :black) 
      black_checker4 = Checker.new(6, 6, :black) 
      @game.place_checker_on_board(red_checker1)
      @game.place_checker_on_board(red_checker2)
      @game.place_checker_on_board(red_checker3)
      @game.place_checker_on_board(black_checker1) 
      @game.place_checker_on_board(black_checker2)
      @game.place_checker_on_board(black_checker3)
      @game.place_checker_on_board(black_checker4)
      @game.generate_jump_locations_coordinates_list.should == [ 2, 4, 2, 2]
    end
    
    it "should tell when a jump is available (for red)" do
      @game.current_player = :red
      red_checker = Checker.new(3, 3, :red)
      black_checker = Checker.new(4, 4, :black)
      @game.place_checker_on_board(red_checker)
      @game.jump_available?.should == false
      @game.place_checker_on_board(black_checker)
      @game.jump_available?.should == true
    end
    
    it "should tell when a jump is available (for black)" do
      @game.current_player = :black
      red_checker = Checker.new(3, 3, :red)
      black_checker = Checker.new(4, 4, :black)
      @game.place_checker_on_board(black_checker)
      @game.jump_available?.should == false
      @game.place_checker_on_board(red_checker)
      @game.jump_available?.should == true
    end

    it "should tell when a jump is available but it has not been taken (for red)" do
      @game.current_player = :red
      red_checker1 = Checker.new(1, 1, :red)
      red_checker2 = Checker.new(1, 7, :red)  
      black_checker1 = Checker.new(2, 6, :black)
      @game.place_checker_on_board(red_checker1)
      @game.place_checker_on_board(red_checker2)
      @game.place_checker_on_board(black_checker1)
      @game.configure_coordinates([1, 1, 2, 2]) 
      @game.jump_available_and_not_taken?.should == true
      @game.configure_coordinates([1, 7, 3, 5])
      @game.jump_available_and_not_taken?.should == false
    end
    
    it "should remove a checker from the board and decrement opposing checker collection if that checker is jumped (for red)" do
      @game.current_player = :red
      jumping_checker = Checker.new(3, 3, :red)
      jumped_checker = Checker.new(4, 4, :black)
      @game.place_checker_on_board(jumping_checker)
      @game.place_checker_on_board(jumped_checker)
      @game.black_checkers_left.should == 1
      @game.configure_coordinates([3, 3, 5, 5])
      @game.move_validator.should == nil
      @game.board[5][5].should equal(jumping_checker)
      @game.board[4][4].should == nil
      @game.black_checkers_left.should == 0
    end
    
    it "should remove a checker from the board and decrement opposing checker collection if that checker is jumped (for black)" do
      @game.current_player = :black
      jumping_checker = Checker.new(5, 5, :black)
      jumped_checker = Checker.new(4, 4, :red)
      @game.place_checker_on_board(jumping_checker)
      @game.place_checker_on_board(jumped_checker)
      @game.red_checkers_left.should == 1
      @game.configure_coordinates([5, 5, 3, 3])
      @game.move_validator.should == nil
      @game.board[3][3].should equal(jumping_checker)
      @game.board[4][4].should == nil
      @game.red_checkers_left.should == 0
    end
     
    it "should allow jumps if there is an opposing checker in place and a vacant spot to land" do
      jumping_checker = Checker.new(3, 3, :red)
      jumped_checker = Checker.new(4, 4, :black)
      @game.place_checker_on_board(jumping_checker)
      @game.place_checker_on_board(jumped_checker)
      @game.configure_coordinates([3, 3, 5, 5])
      @game.move_validator.should == nil
      @game.board[5][5].should equal(jumping_checker)
      @game.board[4][4].should == nil
    end

    it "should not allow jumps if there its over a players own checker" do
      jumping_checker = Checker.new(3, 3, :red)
      jumped_checker = Checker.new(4, 4, :red)
      @game.place_checker_on_board(jumping_checker)
      @game.place_checker_on_board(jumped_checker)
      @game.configure_coordinates([3, 3, 5, 5])
      @game.move_validator.should == "You cannot jump a checker of your own color"
      @game.board[5][5].should == nil
      @game.board[4][4].should equal(jumped_checker)
      @game.board[3][3].should equal(jumping_checker)
    end

    it "should not allow jumps if there is no vacant space to land" do
      jumping_checker = Checker.new(3, 3, :red)
      jumped_checker = Checker.new(4, 4, :black)
      blocking_checker = Checker.new(5, 5, :black)
      @game.place_checker_on_board(jumping_checker)
      @game.place_checker_on_board(jumped_checker)
      @game.place_checker_on_board(blocking_checker)
      @game.configure_coordinates([3, 3, 5, 5])
      @game.move_validator.should == "You cannot move to an occupied square"
      @game.board[5][5].should equal(blocking_checker) 
      @game.board[4][4].should equal(jumped_checker)
      @game.board[3][3].should equal(jumping_checker)
    end

    it "should force the player to jump if a jump is possible" do
      jumping_checker = Checker.new(3, 3, :red)
      potential_jumped_checker = Checker.new(4, 4, :black)
      @game.place_checker_on_board(jumping_checker)
      @game.place_checker_on_board(potential_jumped_checker)
      @game.configure_coordinates([3, 3, 4, 2])
      @game.move_validator.should == "You must jump if a jump is available"
      @game.board[4][2].should_not equal(jumping_checker)
    end
  end
end
