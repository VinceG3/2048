module Game2048
  class AiInput
    @@last_move = nil
    extend Forwardable
    attr_reader :board, :state, :move
    
    def initialize(board)
      @board = board
      @state = State.determine(board)
    end

    def self.get_input(board)
      new(board).get_input
    end

    def self.set_last_move(direction)
      @@last_move = direction
    end

    def self.last_move
      @@last_move
    end

    def do_move(direction)
      if state[:directions].include?(direction)
        unless move
          self.class.set_last_move(direction)
          @move = direction
          direction
        end
      end
    end

    def dumb_strategy
      order([:down, :right, :left, :up])
    end

    def vince_strategy
      do_move(:right) if state[:combine_bottom]
      do_move(:left) if state[:analyze_last_two_rows] == :shifted
      do_move(:down) if state[:analyze_last_two_rows] == :stright
      # order([:down, :left, :right]) if state[:free_left]
      # order([:down, :right, :up, :left]) if state[:right_column_frozen]
      order([:down, :right, :left, :up])
    end

    def pick_one(directions)
      (directions & state[:directions]).sample
    end

    def order(directions)
      directions.each do |dir|
        do_move(dir)
      end
    end

    def valid_move?
      !board.try(@move)
    end

    def get_input
      vince_strategy
      binding.pry unless valid_move?
      raise("bad move passed") unless valid_move?
      @move
    rescue Interrupt
      binding.pry
    end
  end

  class State
    attr_reader :board

    def initialize(board)
      @board = board
    end

    def self.determine(board)
      new(board).determine
    end

    def try(direction)
      !board.try(direction)
    end

    def determine
      {
        directions: directions,
        bottom_row_frozen: bottom_row_frozen?,
        right_column_frozen: right_column_frozen?,
        largest_in_corner: largest_in_corner?,
        combine_bottom: combine_bottom?,
        last_move: AiInput.last_move,
        analyze_last_two_rows: analyze_last_two_rows,
        snake_active: snake_active?,
        free_left: free_left?
      }
    end

    def combine_bottom?
      combine_right?(board.rows.last.values)
    end

    def combine_right?(values)
      return false if values.reject(&:zero?).empty?
      return false if values.reject(&:zero?).size == Rule.new(values).apply.reject(&:zero?).size
      return true
    end

    def free_left?
      largest_in_corner? and snake_active? and bottom_row_frozen?
    end

    def snake_active?
      largest_in_corner? and (board.rows.last.values.sort == board.rows.last.values)
    end

    def analyze_last_two_rows
      return false unless free_left?
      return :straight if bottom_next_match > 1
      return :shifted if bottom_shift_match > 0
    end

    def bottom_shift_match
      board.rows.last[0..2].&(board.rows[2][1..3]).count 
    end

    def bottom_next_match
      board.rows.last[0..2].&(board.rows[2][0..2]).count
    end

    def bottom_row_frozen?
      (board.rows.last == board.left.rows.last) and
      (board.rows.last == board.right.rows.last)
    end

    def right_column_frozen?
      (board.columns.last == board.up.columns.last) and
      (board.columns.last == board.down.columns.last)
    end

    def largest_in_corner?
      board.values.flatten.last == board.values.flatten.max
    end

    def directions
      [:up, :down, :left, :right].keep_if{|d| try(d) }
    end
  end
end