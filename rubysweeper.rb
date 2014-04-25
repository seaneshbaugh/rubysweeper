class Rubysweeper
  attr_accessor :board, :width, :height

  class Cell
    attr_accessor :bomb, :clicked, :display

    def initialize(bomb = false)
      @bomb = bomb

      @clicked = false

      @display = ' '
    end

    def click
      @clicked = true
    end

    def to_s
      if @clicked
        @display
      else
        '#'
      end
    end
  end

  def initialize(width, height)
    @width = width

    @height = height

    @board = Array.new

    @width.times do
      row = Array.new

      @height.times do
        row << Cell.new(rand(10) == 1)
      end

      @board << row
    end

    @width.times do |x|
      @height.times do |y|
        if @board[x][y].bomb
          @board[x][y].display = '*'
        else
          neighbors = 0

          if x - 1 < 0
            sx = 0
          else
            sx = x - 1
          end

          if x + 1 >= @width
            ex = @width - 1
          else
            ex = x + 1
          end

          if y - 1 < 0
            sy = 0
          else
            sy = y -1
          end

          if y + 1 >= @height
            ey = @height - 1
          else
            ey = y +1
          end

          (sx..ex).each do |nx|
            (sy..ey).each do |ny|
              neighbors += 1 if @board[nx][ny].bomb
            end
          end

          if neighbors > 0
            @board[x][y].display = neighbors.to_s
          else
            @board[x][y].display = ' '
          end
        end
      end
    end
  end

  def play!
    display_board

    loop do
      input = get_input

      click(input.first, input.last)

      if lose?
        @width.times do |x|
          @height.times do |y|
            @board[x][y].click
          end
        end

        display_board

        puts 'You lose!'

        break
      end

      if win?
        puts 'You win!'

        break
      end

      display_board
    end
  end

  def get_input
    x = nil

    y = nil

    loop do
      puts

      print "Enter a pair of coordinates between (0, 0) and (#{@width - 1}, #{@height - 1}): "

      coordinates = $stdin.gets

      x_y = coordinates.split(',')

      if x_y.length == 2
        begin
          x = Integer(x_y.first.strip)

          y = Integer(x_y.last.strip)

          if x >= 0 && x < @width && y >= 0 && y < @height
            break
          end
        rescue
          nil
        end
      end

      puts 'Not a valid coordinate.'
    end

    [x, y]
  end

  def click(x, y, l = [])
    @board[x][y].click

    if @board[x][y].bomb && l.empty?
      @board[x][y].display = '!'
    end

    if !@board[x][y].bomb && @board[x][y].display == ' ' && !l.member?([x, y])
      if x - 1 < 0
        sx = 0
      else
        sx = x - 1
      end

      if x + 1 >= @width
        ex = @width - 1
      else
        ex = x + 1
      end

      if y - 1 < 0
        sy = 0
      else
        sy = y -1
      end

      if y + 1 >= @height
        ey = @height - 1
      else
        ey = y +1
      end

      (sx..ex).each do |nx|
        (sy..ey).each do |ny|
          if !(x == nx && y == ny)
            click(nx, ny, l << [x, y] )
          end
        end
      end
    end
  end

  def display_board
    print "\e[H\e[2J"

    left_padding = @height.to_s.length + 2

    top_padding = @width.to_s.length

    top_padding.times do |x|
      print ' ' * (left_padding)

      @width.times do |y|
        print y.to_s.rjust(top_padding)[x]
      end

      puts
    end

    puts ' ' * left_padding + ' ' * (@board.length + 2)

    y = 0

    @board.each do |row|
      print "#{y.to_s.rjust(@height.to_s.length)}  "

      row.each do |cell|
        print cell
      end

      puts

      y += 1
    end

    puts ' ' * left_padding + ' ' * (@board.length + 2)
  end

  def win?
    clicked = 0

    bombs = 0

    @board.each do |row|
      row.each do |cell|
        return false if cell.clicked && cell.bomb

        if cell.clicked
          clicked += 1
        end

        if cell.bomb
          bombs += 1
        end
      end
    end

    return clicked + bombs == @width * @height
  end

  def lose?
    display_board

    @board.each do |row|
      row.each do |cell|
        return true if cell.clicked && cell.bomb
      end
    end

    false
  end
end

width = 10

height = 10

if ARGV.length == 1
  width = height = ARGV[0].to_i
elsif ARGV.length > 1
  width = ARGV[0].to_i

  height = ARGV[1].to_i
end

if width < 10
  width = 10
elsif width > 50
  width = 50
end

if height < 10
  height = 10
elsif height > 50
  height = 50
end

Rubysweeper.new(width, height).play!
