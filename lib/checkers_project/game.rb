class Game
  
  attr_accessor :board, :gui

  def initialize
    @gui = BasicGui.new
    @current_player = :red
    @board = create_board
    play_game
  end

  def play_game
    puts intro

    #while(won? == false)
    @gui.render_board(@board)
    print move_request
    move_coordinates = gets 
    coord_array = move_coordinates.chomp.split(',')
    x1 = coord_array[0].to_i
    y1 = coord_array[1].to_i
    x2 = coord_array[2].to_i
    y2 = coord_array[3].to_i
    puts move_validator(x1, y1, x2, y2)
    @gui.render_board(@board)
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
    @board[checker.x_pos][checker.y_pos] = checker 
  end

  def populate_checkers
    evens = [0, 2, 4, 6]
    odds  = [1, 3, 5, 7]

    0.upto(2) do |x_coord|
      if x_coord.even?
        evens.each do |y_coord|
          @board[x_coord][y_coord] = Checker.new(x_coord, y_coord, :red)
        end
      elsif x_coord.odd?
        odds.each do |y_coord|
          @board[x_coord][y_coord] = Checker.new(x_coord, y_coord, :red)
        end
      end
    end

    5.upto(7) do |x_coord|
      if x_coord.even?
        evens.each do |y_coord|
        @board[x_coord][y_coord] = Checker.new(x_coord, y_coord, :black)
      end
      elsif x_coord.odd?
        odds.each do |y_coord|
        @board[x_coord][y_coord] = Checker.new(x_coord, y_coord, :black)
        end
      end
    end
  end

  def move_validator(x_origin, y_origin, x_dest, y_dest)
    coords = [x_origin, y_origin, x_dest, y_dest]
    
    case 
    when out_of_bounds?(coords) == true
      message = "You cannot move off the board"
    
    when no_checker_at_origin(coords) == true
      message = "There is no checker to move in requested location"
    
    when attempted_non_diagonal_move(coords) == true
      message = "You can only move a checker diagonally"
    
    when attempted_move_to_occupied_square(coords) == true
      message = "You cannot move to an occupied square"
    
    when non_king_moving_backwards(coords) == true
      message = "A non-king checker cannot move backwards"
    
    when attempted_jump_of_own_checker(coords)
      message = "You cannot jump a checker of your own color"
    
    when jump_available_and_not_taken?(coords) == true
      message = "You must jump if a jump is available"  
    
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
    x2 = coords[2]
    y2 = coords[3]

    jump_positions = { "upper_left"  => board[x1 + 1][y1 + 1],
                       "upper_right" => board[x1 + 1][y1 - 1],
                       "lower_left"  => board[x1 - 1][y1 - 1],
                       "lower_right" => board[x1 - 1][y1 - 1] }  
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
  
  def jump_available_and_not_taken?(coords)
    x1_orig = coords[0]
    y1_orig = coords[1]
    x2_orig = coords[2]
    y2_orig = coords[3] 
    
    map = coords.dup
    x1 = map[0]
    y1 = map[1]
    x2 = map[2]
    y2 = map[3]
    
    

    jumpable_checkers = opposing_checker_adjacent(coords)
    
    result = false    

    if ((jumpable_checkers["upper_left"] == true) and (board[x1_orig + 2][y1_orig + 2].nil?) and (out_of_bounds?(coord_help(x1 += 2, y1 += 2, map)) == false) and ((x2_orig != x1_orig + 2) and (y2_orig != y1_orig + 2)))
        
        result = true
    elsif ((jumpable_checkers["upper_right"] == true) and (board[x1_orig + 2][y1_orig - 2].nil?) and (out_of_bounds?(coord_help(x1 += 2, y1 -= 2, map)) == false) and ((x2_orig != x1_orig + 2) and (y2_orig != y1_orig - 2)))
        
        result = true
    end
    
    if board[coords[0]][coords[1]].isKing?

      if ((jumpable_checkers["lower_left"] == true) and (board[x1_orig - 2][y1_orig + 2].nil?) and (out_of_bounds? (coord_help(x1 -= 2, y1 += 2, map)) == false) and ((x2_orig != x1_orig - 2) and (y2_orig != y1_orig + 2)))
        
        result = true
      elsif ((jumpable_checkers["lower_right"] == true) and (board[x1_orig - 2][y1_orig -2].nil?) and (out_of_bounds? (coord_help(x1 -= 2, y1 -= 2, map))== false) and ((x2_orig != x1_orig - 2) and (y2_orig != y1_orig - 2)))
        
        result = true     
      end
    end

    result
  end          
  
  def coord_help(function1, function2, array)
    function1
    function2
    array
  end

  def attempted_jump_of_own_checker(coords)
    if jumping_move?(coords)
      x1 = coords[0]
      y1 = coords[1]
      x2 = coords[2]
      y2 = coords[3]
    
      x_delta = (x2 > x1) ? 1 : -1
      y_delta = (y2 > y1) ? 1 : -1
    
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
    
    @board[remove_checker_x_value][remove_checker_y_value] = nil
  end

  def out_of_bounds?(coords)
    x = coords[2]
    y = coords[3]

   (x < 0  or y < 0) or (x > 7  or y > 7)
  end

  def no_checker_at_origin(coords)
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

    (x2 < x1) and (board[x1][y1].isKing? == false)
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
