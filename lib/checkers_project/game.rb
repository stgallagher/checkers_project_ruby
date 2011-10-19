

class Game
  
  attr_accessor :board, :gui, :red_checkers, :black_checkers, :current_player
  
  def initialize
    @red_checkers   = Array.new
    @black_checkers = Array.new
    @gui = BasicGui.new
    @current_player = :red
    @board = create_board
    
    #play_game
  end

  def play_game
    puts intro

    while(won? == false)
      message = nil
      @gui.render_board(@board)
      print move_request
      move_coordinates = gets 
      coord_array = move_coordinates.chomp.split(',')
      x1 = coord_array[0].to_i
      y1 = coord_array[1].to_i
      x2 = coord_array[2].to_i
      y2 = coord_array[3].to_i
      if @current_player == :black
        x1 = 7 - x1
        y1 = 7 - y1
        x2 = 7 - x2
        y2 = 7 - y2
      end
      puts message = move_validator(x1, y1, x2, y2)
      if(message == nil)
        @current_player = switch_player
      end
    end  
  end
  
  def won?
    false
  end

  def switch_player
    @current_player == :red ? :black : :red
  end

  def intro
    'Welcome to Checkers!'
  end
  
  def move_request
    "#{@current_player.upcase} make move(x1, y1, x2, y2): "
  end

  def create_board
    @board = Array.new(8)
    8.times { |index| @board[index] = Array.new(8) }
    populate_checkers
    @board
  end
  
  def create_test_board
    @board = Array.new(8)
    8.times { |index| @board[index] = Array.new(8) }
    @board
  end

  def place_checker_on_board(checker)
    if checker.color == :red
      @red_checkers << checker
    else
      @black_checkers << checker
    end
    @board[checker.x_pos][checker.y_pos] = checker 
  end

  def populate_checkers
    evens = [0, 2, 4, 6]
    odds  = [1, 3, 5, 7]

    0.upto(2) do |x_coord|
      if x_coord.even?
        evens.each do |y_coord|
          red_checker = Checker.new(x_coord, y_coord, :red)
          @board[x_coord][y_coord] = red_checker 
          @red_checkers << red_checker
        end
      elsif x_coord.odd?
        odds.each do |y_coord|
          red_checker = Checker.new(x_coord, y_coord, :red)
          @board[x_coord][y_coord] = red_checker 
          @red_checkers << red_checker
        end
      end
    end

    5.upto(7) do |x_coord|
      if x_coord.even?
        evens.each do |y_coord|
          black_checker = Checker.new(x_coord, y_coord, :black)
          @board[x_coord][y_coord] = black_checker 
          @black_checkers << black_checker
      end
      elsif x_coord.odd?
        odds.each do |y_coord|
          black_checker = Checker.new(x_coord, y_coord, :black)
          @board[x_coord][y_coord] = black_checker 
          @black_checkers << black_checker
        end
      end
    end
  end

  def move_validator(x_origin, y_origin, x_dest, y_dest)
    coords = [x_origin, y_origin, x_dest, y_dest]
    
    message = nil

    case 
    when out_of_bounds?(x_dest, y_dest) == true
      message = "You cannot move off the board"
    
    when no_checker_at_origin?(coords) == true
      message = "There is no checker to move in requested location"
    
    when attempted_non_diagonal_move(coords) == true
      message = "You can only move a checker diagonally"
    
    when attempted_move_to_occupied_square(coords) == true
      message = "You cannot move to an occupied square"
    
    when non_king_moving_backwards(coords) == true
      message = "A non-king checker cannot move backwards"
    
    when attempted_jump_of_own_checker(coords)
      message = "You cannot jump a checker of your own color"
    
    #when jump_available_and_not_taken?(coords) == true
    #  message = "You must jump if a jump is available"  
    
    else
      move(coords[0], coords[1], coords[2], coords[3])
      
      if jumping_move?(coords)
        remove_jumped_checker(coords)
      end
    end
    message
  end
  
  def adjacent_positions(coords)
    x1 = coords[0]
    y1 = coords[1]
    
    jump_positions = { "upper_left"  => board[x1 + 1][y1 + 1],
                       "upper_right" => board[x1 + 1][y1 - 1],
                       "lower_left"  => board[x1 - 1][y1 + 1],
                       "lower_right" => board[x1 - 1][y1 - 1] }  
    
    if @current_player == :black
      jump_positions = { "upper_left"  => board[x1 - 1][y1 - 1],
                         "upper_right" => board[x1 - 1][y1 + 1],
                         "lower_left"  => board[x1 + 1][y1 - 1],
                         "lower_right" => board[x1 + 1][y1 + 1] }
    end  
    jump_positions
  end

  def opposing_checker_adjacent(coords)
    opposing_checkers = adjacent_positions(coords)

    if  ((opposing_checkers["upper_left"] != nil) and (opposing_checkers["upper_left"].color != @current_player))
      opposing_checkers["upper_left"] = true
    end
    
    if  ((opposing_checkers["upper_right"] != nil) and (opposing_checkers["upper_right"].color != @current_player))
      opposing_checkers["upper_right"] = true
    end
    
    if  ((opposing_checkers["lower_left"] != nil) and (opposing_checkers["lower_left"].color != @current_player))
      opposing_checkers["lower_left"] = true
    end
    
    if  ((opposing_checkers["lower_right"] != nil) and (opposing_checkers["lower_right"].color != @current_player))
      opposing_checkers["lower_right"] = true
    end
   
    opposing_checkers
  end
  
  def jump_locations(coords) 
    opposing_checkers = opposing_checker_adjacent(coords)
     
    jump_locations = { "upper_left"  => false,
                       "upper_right" => false,
                       "lower_left"  => false,
                       "lower_right" => false } 
    x1 = coords[0]
    y1 = coords[1]
    
    checker = @board[x1][y1]
    
    if(opposing_checkers["upper_left"] == true) and 
      (out_of_bounds?(x1 + 2, y1 + 2) == false) and
      (board[x1 + 2][y1 + 2] == nil)

      jump_locations["upper_left"] = true
    end
    
    if(opposing_checkers["upper_right"] == true) and 
      (out_of_bounds?(x1 + 2, y1 - 2) == false) and
      (board[x1 + 2][y1 - 2] == nil)

      jump_locations["upper_right"] = true
    end
    
    if(checker.isKing? == true)
      
      if(opposing_checkers["lower_left"] == true) and 
        (out_of_bounds?(x1 - 2, y1 + 2) == false) and
        (board[x1 - 2][y1 + 2] == nil)

        jump_locations["lower_left"] = true
      end

      if(opposing_checkers["lower_right"] == true) and 
        (out_of_bounds?(x1 - 2, y1 - 2) == false) and
        (board[x1 - 2][y1 - 2] == nil)
  
        jump_locations["lower_right"] = true
      end
    end

    if @current_player == :black
      
      jump_locations = { "upper_left"  => false,
                         "upper_right" => false,
                         "lower_left"  => false,
                         "lower_right" => false }

      if(opposing_checkers["upper_left"] == true) and 
        (out_of_bounds?(x1 - 2, y1 - 2) == false) and
        (board[x1 - 2][y1 - 2] == nil)

        jump_locations["upper_left"] = true
      end
    
      if(opposing_checkers["upper_right"] == true) and 
        (out_of_bounds?(x1 - 2, y1 + 2) == false) and
        (board[x1 - 2][y1 + 2] == nil)
        
        jump_locations["upper_right"] = true
      end
      
      if(checker.isKing? == true)
          
        if(opposing_checkers["lower_left"] == true) and 
          (out_of_bounds?(x1 + 2, y1 - 2) == false) and
          (board[x1 + 2][y1 - 2] == nil)

          jump_locations["lower_left"] = true
        end

        if(opposing_checkers["lower_right"] == true) and 
          (out_of_bounds?(x1 + 2, y1 + 2) == false) and
          (board[x1 + 2][y1 + 2] == nil)

          jump_locations["lower_right"] = true
        end
      end
    end
  jump_locations
  end
  
  def jump_locations_coordinates(coords)
    locations = jump_locations(coords)
    
    x1 = coords[0]
    y1 = coords[1]

    jump_coords = []
    
    if @current_player == :red
      if locations["upper_left"]  == true
        jump_coords << [x1 + 2, y1 + 2]
      end
      if locations["upper_right"] == true
        jump_coords << [x1 + 2, y1 - 2] 
      end
      if locations["lower_left"]  == true
        jump_coords << [x1 - 2, y1 + 2]
      end
      if locations["lower_right"] == true
        jump_coords << [x1 - 2, y1 - 2]
      end
    end

    if @current_player == :black
      if locations["upper_left"]  == true
        jump_coords << [x1 - 2, y1 - 2]
      end
      if locations["upper_right"] == true
        jump_coords << [x1 - 2, y1 + 2] 
      end
      if locations["lower_left"]  == true
        jump_coords << [x1 + 2, y1 - 2]
      end
      if locations["lower_right"] == true
        jump_coords << [x1 + 2, y1 + 2]
      end
    end
    jump_coords
  end
  
  def generate_jump_locations_coordinates_list
    coordinates_list = []
    coords = []
    @board.each do |row|
      row.each do |loc|
        if (loc != nil) and (loc.color == @current_player)
          coords = [loc.x_pos, loc.y_pos]
          coordinates_list << jump_locations_coordinates(coords)
        end
      end
    end
    coordinates_list.flatten
  end

  def jump_available_and_not_taken?(coords)
    x_dest = coords[2]
    y_dest = coords[3]
    
    jump_possiblities = generate_jump_locations_coordinates_list
    
    not_taken_jump = true
    jump_possiblities.each_slice(2) do |i|
      if(i[0] == x_dest) and (i[1] == y_dest)
        not_taken_jump = false
      end
    end
    
    not_taken_jump   
  end          

  def attempted_jump_of_own_checker(coords)
    if jumping_move?(coords)
      x1 = coords[0]
      y1 = coords[1]
      x2 = coords[2]
      y2 = coords[3]
      
      x_delta = (x2 > x1) ? 1 : -1
      y_delta = (y2 > y1) ? 1 : -1
      
      if @current_player == :black
       x_delta = (x2 < x1) ? -1 : 1
       y_delta = (y2 < y1) ? -1 : 1
     end
 
      jumped_checker_x_value = x1 + x_delta
      jumped_checker_y_value = y1 + y_delta
    
      jumped_checker = @board[jumped_checker_x_value][jumped_checker_y_value]
      jumping_checker = @board[x1][y1]

      jumped_checker.color == jumping_checker.color
    end
  end

  def jumping_move?(coords)
    x1 = coords[0]
    y1 = coords[1]
    x2 = coords[2]
    y2 = coords[3]
    
    (x2 - x1).abs > 1 
  end
  
  def remove_jumped_checker(coords)
    x1 = coords[0]
    y1 = coords[1]
    x2 = coords[2]
    y2 = coords[3]
    
    x_delta = (x2 > x1) ? 1 : -1
    y_delta = (y2 > y1) ? 1 : -1
    
    remove_checker_x_value = x1 + x_delta
    remove_checker_y_value = y1 + y_delta
    
    
    removed_checker = @board[remove_checker_x_value][remove_checker_y_value]
    @board[remove_checker_x_value][remove_checker_y_value] = nil
    if @current_player == :red
      @black_checkers.delete(removed_checker)
    else
      @red_checkers.delete(removed_checker)
    end
  end

  def out_of_bounds?(x, y)
   (x < 0  or y < 0) or (x > 7  or y > 7)
  end

  def no_checker_at_origin?(coords)
    x = coords[0]
    y = coords[1]
    
    @board[x][y].nil?
  end

  def attempted_non_diagonal_move(coords)
    x1 = coords[0]
    y1 = coords[1]
    x2 = coords[2]
    y2 = coords[3]

    (x1 == x2) or (y1 == y2)
  end

  def attempted_move_to_occupied_square(coords)
    x = coords[2]
    y = coords[3]
    not board[x][y].nil?
  end
  
  def non_king_moving_backwards(coords)
    x1 = coords[0]
    y1 = coords[1]
    x2 = coords[2]
    
    if @current_player == :red 
      (x2 < x1) and (board[x1][y1].isKing? == false)
    else
      (x2 > x1) and (board[x1][y1].isKing? == false)
    end
  end

  def move(x_origin, y_origin, x_dest, y_dest)

    # get checker thats moving
    moving_checker = @board[x_origin][y_origin]
    
    # set new location for checker
    moving_checker.x_pos = x_dest
    moving_checker.y_pos = y_dest

    # update board positions of checker
    @board[x_origin][y_origin] = nil
    @board[x_dest][y_dest] = moving_checker
  end
end
