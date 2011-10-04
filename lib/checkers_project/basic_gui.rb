class BasicGui

  def render_board(board)
    board_display = []

    0.upto(7) do |x_coord|
      0.upto(7) do |y_coord|
        if board[x_coord][y_coord].nil?
          if (x_coord.even? && y_coord.odd?) || (x_coord.odd? && y_coord.even?)
          board_display << "#"
          elsif x_coord.even? && y_coord.even? || (x_coord.odd? && y_coord.odd?)
          board_display << " "
          end
        elsif board[x_coord][y_coord].color == :red
          board_display << "R"
        elsif board[x_coord][y_coord].color == :black
          board_display << "B"
        end
      end
      board_display << "\n"
    end
    board_display.to_s
  end
end
