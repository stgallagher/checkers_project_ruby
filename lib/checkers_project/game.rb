

class Game
  
  attr_accessor :board, :gui, :red_checkers, :black_checkers, :current_player , :x_orig, :y_orig, :x_dest, :y_dest, :x_scan, :y_scan 
                
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

    while(game_over? == false)
      message = nil
      @gui.render_board(@board)
      print move_request
      player_input = gets 
      coordinates = translate_move_request_to_coordinates(player_input) 
      configure_coordinates(coordinates)

      message = move_validator
      puts message unless message.nil?
      if(message == nil)
        @current_player = switch_player
      end
    end  
  end
  
  def configure_coordinates(coordinates)
    @x_orig = coordinates[0]
    @y_orig = coordinates[1]
    @x_dest = coordinates[2]
    @y_dest = coordinates[3]
  end

  def translate_move_request_to_coordinates(move_request)
    coords_array = move_request.chomp.split(',').map { |x| x.to_i }
  end

  def game_over?
    (@red_checkers.count == 0) or (@black_checkers.count == 0)
  end

  def switch_player
    @current_player == :red ? :black : :red
  end

  def intro
    'Welcome to Checkers!'
  end
  
  def move_request
    "#{@current_player.to_s.upcase} make move(x1, y1, x2, y2): "
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

  def move_validator

    message = nil
    

    case 
    when out_of_bounds?(@x_dest, @y_dest) == true
      message = "You cannot move off the board"
      
    when no_checker_at_origin? == true
      message = "There is no checker to move in requested location"
      
    when attempted_non_diagonal_move == true
      message = "You can only move a checker diagonally"
      
    when attempted_move_to_occupied_square == true
      message = "You cannot move to an occupied square"
      
    when non_king_moving_backwards == true
      message = "A non-king checker cannot move backwards"
      
    when attempted_jump_of_own_checker
      message = "You cannot jump a checker of your own color"
      
    when jump_available_and_not_taken? == true
      message = "You must jump if a jump is available"  
      
    
    else
      
      move
      
      if jumping_move?
        remove_jumped_checker
      end
    end
    message
  end
  
  def adjacent_positions
    
    if @current_player == :red

      jump_positions = { "upper_left"  => board[@x_scan + 1][@y_scan + 1],
                         "upper_right" => board[@x_scan + 1][@y_scan - 1],
                         "lower_left"  => board[@x_scan - 1][@y_scan + 1],
                         "lower_right" => board[@x_scan - 1][@y_scan - 1] }  
    end

    if @current_player == :black
      if @x_scan < 7
        jump_positions = { "upper_left"  => board[@x_scan - 1][@y_scan - 1],
                           "upper_right" => board[@x_scan - 1][@y_scan + 1], 
                           "lower_left"  => board[@x_scan + 1][@y_scan - 1],
                           "lower_right" => board[@x_scan + 1][@y_scan + 1] }
      else
      jump_positions = { "upper_left"  => board[@x_scan - 1][@y_scan - 1],
                         "upper_right" => board[@x_scan - 1][@y_scan + 1], 
                         "lower_left"  => nil,
                         "lower_right" => nil }
      end  
    end
    
    jump_positions
  end

  def opposing_checker_adjacent
    opposing_checkers = adjacent_positions

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
  
  def jump_locations 
    opposing_checkers = opposing_checker_adjacent
     
    jump_locations = { "upper_left"  => false,
                       "upper_right" => false,
                       "lower_left"  => false,
                       "lower_right" => false } 
    
    checker = @board[@x_scan][@y_scan]
    
    if(opposing_checkers["upper_left"] == true) and 
      (out_of_bounds?(@x_scan + 2, @y_scan + 2) == false) and
      (board[@x_scan + 2][@y_scan + 2] == nil)

      jump_locations["upper_left"] = true
    end
    
    if(opposing_checkers["upper_right"] == true) and 
      (out_of_bounds?(@x_scan + 2, @y_scan - 2) == false) and
      (board[@x_scan + 2][@y_scan - 2] == nil)

      jump_locations["upper_right"] = true
    end
    
    if(checker.isKing? == true)
      
      if(opposing_checkers["lower_left"] == true) and 
        (out_of_bounds?(@x_scan - 2, @y_scan + 2) == false) and
        (board[@x_scan - 2][@y_scan + 2] == nil)

        jump_locations["lower_left"] = true
      end

      if(opposing_checkers["lower_right"] == true) and 
        (out_of_bounds?(@x_scan - 2, @y_scan - 2) == false) and
        (board[@x_scan - 2][@y_scan - 2] == nil)
  
        jump_locations["lower_right"] = true
      end
    end

    if @current_player == :black
      
      jump_locations = { "upper_left"  => false,
                         "upper_right" => false,
                         "lower_left"  => false,
                         "lower_right" => false }

      if(opposing_checkers["upper_left"] == true) and 
        (out_of_bounds?(@x_scan - 2, @y_scan - 2) == false) and
        (board[@x_scan - 2][@y_scan - 2] == nil)

        jump_locations["upper_left"] = true
      end
    
      if(opposing_checkers["upper_right"] == true) and 
        (out_of_bounds?(@x_scan - 2, @y_scan + 2) == false) and
        (board[@x_scan - 2][@y_scan + 2] == nil)
        
        jump_locations["upper_right"] = true
      end
      
      if(checker.isKing? == true)
          
        if(opposing_checkers["lower_left"] == true) and 
          (out_of_bounds?(@x_scan + 2, @y_scan - 2) == false) and
          (board[@x_scan + 2][@y_scan - 2] == nil)

          jump_locations["lower_left"] = true
        end

        if(opposing_checkers["lower_right"] == true) and 
          (out_of_bounds?(@x_scan + 2, @y_scan + 2) == false) and
          (board[@x_scan + 2][@y_scan + 2] == nil)

          jump_locations["lower_right"] = true
        end
      end
    end
    
  jump_locations
  end
  
  def jump_locations_coordinates
    locations = jump_locations
    
    jump_coords = []
    
    if @current_player == :red
      if locations["upper_left"]  == true
        jump_coords << [@x_scan + 2, @y_scan + 2]
      end
      if locations["upper_right"] == true
        jump_coords << [@x_scan + 2, @y_scan - 2] 
      end
      if locations["lower_left"]  == true
        jump_coords << [@x_scan - 2, @y_scan + 2]
      end
      if locations["lower_right"] == true
        jump_coords << [@x_scan - 2, @y_scan - 2]
      end
    end

    if @current_player == :black
      if locations["upper_left"]  == true
        jump_coords << [@x_scan - 2, @y_scan - 2]
      end
      if locations["upper_right"] == true
        jump_coords << [@x_scan - 2, @y_scan + 2] 
      end
      if locations["lower_left"]  == true
        jump_coords << [@x_scan + 2, @y_scan - 2]
      end
      if locations["lower_right"] == true
        jump_coords << [@x_scan + 2, @y_scan + 2]
      end
    end
    
    jump_coords
  end
  
  def generate_jump_locations_coordinates_list
    coordinates_list = []

    @board.each do |row|
      row.each do |loc|
        if (loc != nil) and (loc.color == @current_player)
          @x_scan = loc.x_pos
          @y_scan = loc.y_pos
          coordinates_list << jump_locations_coordinates
        end
      end
    end
    
    coordinates_list.flatten
  end
  
  def jump_available?
    possible_jumps = generate_jump_locations_coordinates_list
    
    possible_jumps.size > 0
  end
  
  def jump_available_and_not_taken?
    jump_possiblities = generate_jump_locations_coordinates_list
    
    not_taken_jump = true
    jump_possiblities.each_slice(2) do |i|
      if(i[0] == @x_dest) and (i[1] == @y_dest)
        not_taken_jump = false
      end
    end
    
    (jump_available? == true) and (not_taken_jump)   
  end          

  def attempted_jump_of_own_checker
    if jumping_move?
      x_delta = (@x_dest > @x_orig) ? 1 : -1
      y_delta = (@y_dest > @y_orig) ? 1 : -1
      
      if @current_player == :black
       x_delta = (@x_dest < @x_orig) ? -1 : 1
       y_delta = (@y_dest < @y_orig) ? -1 : 1
     end
 
      jumped_checker_x_value = @x_orig + x_delta
      jumped_checker_y_value = @y_orig + y_delta
    
      jumped_checker = @board[jumped_checker_x_value][jumped_checker_y_value]
      jumping_checker = @board[@x_orig][@y_orig]

      jumped_checker.color == jumping_checker.color
    end
  end

  def jumping_move?
    (@x_dest - @x_orig).abs > 1 
  end
  
  def remove_jumped_checker
    x_delta = (@x_dest > @x_orig) ? 1 : -1
    y_delta = (@y_dest > @y_orig) ? 1 : -1
    
    remove_checker_x_value = @x_orig + x_delta
    remove_checker_y_value = @y_orig + y_delta
    
    
    removed_checker = @board[remove_checker_x_value][remove_checker_y_value]
    @board[remove_checker_x_value][remove_checker_y_value] = nil
    if @current_player == :red
      @black_checkers.delete(removed_checker)
    else
      @red_checkers.delete(removed_checker)
    end
  end

  def out_of_bounds?(x, y)
   ( x < 0  or y < 0) or (x > 7  or y > 7)
  end

  def no_checker_at_origin?
    @board[@x_orig][@y_orig].nil?
  end

  def attempted_non_diagonal_move
    (@x_orig == @x_dest) or (@y_orig == @y_dest)
  end

  def attempted_move_to_occupied_square
    not board[@x_dest][@y_dest].nil?
  end
  
  def non_king_moving_backwards
    if @current_player == :red 
      (@x_dest < @x_orig) and (board[@x_orig][@y_orig].isKing? == false)
    else
      (@x_dest > @x_orig) and (board[@x_orig][@y_orig].isKing? == false)
    end
  end

  def move
    #moving
    moving_checker = @board[@x_orig][@y_orig]

    # set new location for checker
    moving_checker.x_pos = @x_dest
    moving_checker.y_pos = @y_dest

    # update board positions of checker
    @board[@x_orig][@y_orig] = nil
    @board[@x_dest][@y_dest] = moving_checker
  end

  def set_scan_values(x, y)
    @x_scan = x
    @y_scan = y
  end
end
