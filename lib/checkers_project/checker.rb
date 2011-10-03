class Checker
  attr_accessor :location, :color, :king_status

  def initialize (x_location, y_location, color)
    @location = [x_location, y_location]
    @color = color
    @king_status = false
  end

  def isKing?
    return @king_status
  end

  def make_king
    @king_status = true
  end
end
