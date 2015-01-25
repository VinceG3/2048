require 'colorize'

module Game2048
  class ConsoleDisplay
    attr_reader :board

    def initialize(board)
      @board = board
      @lines = {}
    end

    def self._display(board)
      new(board)._display
    end

    def _display
      clear_screen
      make_lines
      write_lines
    end

    def clear_screen
      puts "\e[H\e[2J"
    end

    def make_lines
      elements.each_with_index do |row, y|
        row.each_with_index do |klass, x|
          add_lines(klass.new(board, x, y).scan)
        end
      end
    end

    def write_lines
      @lines.each do |k, v|
        puts v
      end
    end

    def add_lines(lines)
      lines.each do |k, v|
        @lines[k] ||= ""
        @lines[k] << v
      end
    end

    def elements
      [
        [ AllSides, AllButLeft, AllButLeft, AllButLeft ],
        [ AllButTop, AllButTopLeft, AllButTopLeft, AllButTopLeft ],
        [ AllButTop, AllButTopLeft, AllButTopLeft, AllButTopLeft ],
        [ AllButTop, AllButTopLeft, AllButTopLeft, AllButTopLeft ]
      ]
    end

    class Cell
      attr_reader :value, :x, :y
      def initialize(board, x, y)
        @x = x; @y = y
        @value = board.rows[y][x]
        @lines = {}
        @line = initial_line
      end

      def count
        @line += 1
      end

      def initial_line
        case y
        when 0
          0
        when 1
          5
        when 2
          9
        when 3
          13
        end
      end

      def add(string)
        @lines[@line] ||= ""
        @lines[@line] << string
        count
      end

      def scan
        write
        return @lines
      end

      def padded
        case value
        when 0
          "    "
        when 2
          "   2".underline
        when 4
          "   4".cyan.underline
        when 8
          "   8".light_red.underline
        when 16
          "  16".yellow.underline
        when 32
          "  32".red.underline
        when 64
          "  64".green.underline
        when 128
          " 128".blue.underline
        when 256
          " 256".light_magenta.underline
        when 512
          " 512".light_cyan.underline
        when 1024
          "1024".light_yellow.underline
        when 2048
          "2048".magenta.underline
        else
          binding.pry
        end
      end
    end

    class AllSides < Cell
      def write
        add "+------+"
        add "|      |"
        add "| #{padded} |"
        add "|      |"
        add "+------+"
      end
    end

    class AllButLeft < Cell
      def write
        add "------+"
        add "      |"
        add " #{padded} |"
        add "      |"
        add "------+"
      end
    end

    class AllButTop < Cell
      def write
        add "|      |"
        add "| #{padded} |"
        add "|      |"
        add "+------+"
      end
    end

    class AllButTopLeft < Cell
      def write
        add "      |"
        add " #{padded} |"
        add "      |"
        add "------+"
      end
    end
  end

  class NoOutput
    def self._display(board)
    end

    def self.write_stats(stats)
      puts; puts
      stats[:largest].each do |v, c|
        puts "#{v} was reached #{c} times."
      end
      puts
      puts "total score is: #{stats[:scores].reduce(:+)}"
      average = stats[:scores].reduce(:+)./(stats[:scores].size)
      puts "average score is: #{average}"
    end

    def self.write_stat(stat)
      puts stat
    end
  end
end