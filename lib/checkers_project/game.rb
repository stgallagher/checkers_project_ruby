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
