class Game
  
  attr_accessor :board, :gui

  def initialize
    @gui = BasicGui.new
    create_board
  end

  def create_board
    @board = Array.new(8)
    8.times { |index| @board[index] = Array.new(8) }
    populate_checkers
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
    when out_of_bounds(coords) == true
      message = "You cannot move off the board"
    when no_checker_at_origin(coords) == true
      message = "There is no checker to move in requested location"
    when attempted_non_diagonal_move(coords) == true
      message = "You can only move a checker diagonally"
    when attempted_move_to_occupied_square(coords) == true
      message = "You cannot move to an occupied square"
    when non_king_moving_backwards(coords) == true
      message = "A non-king checker cannot move backwards"
    end
    message
  end
  
  def out_of_bounds(coords)
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
