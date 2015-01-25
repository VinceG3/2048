module Game2048
  class Board
    attr_reader :values

    EmptyBoard = [[0, 0, 0, 0], 
                  [0, 0, 0, 0], 
                  [0, 0, 0, 0], 
                  [0, 0, 0, 0]]

    def initialize(values = EmptyBoard)
      @values = values
    end

    def [](index)
      binding.pry
    end

    def set(index, value)
      v = values.clone
      i = index./(4)
      row = rows[i]
      new_row = row.set(index.%(4), value)
      v[i] = new_row
      return Board.new(v)
    end

    def rows
      Row.from_board(self)
    end

    def columns
      Column.from_board(self)
    end

    def score
      values.flatten.reduce(:+)
    end

    def ==(other)
      other.values == values
    end

    def win?
      values.flatten.any?{|value| value == 2048 }
    end

    def largest
      values.flatten.max
    end

    def lose?
      [:up, :down, :right, :left].collect{|dir| try(dir)}.all?{|q|q}
    end

    def try(dir)
      return false if self != send(dir)
      return true
    end

    def random_empty_space
      values.
        flatten.
        each_with_index.select{|v, i| v.zero? }.
        collect{|a| a[1]}.
        sample
    end

    def random_value
      rand(0..9) == 0 ? 4 : 2
    end

    def add_value
      value = random_value
      space = random_empty_space
      self.set(space, value)
    end

    def self.create
      board = new
      board = board.add_value
      board = board.add_value
      return board
    end

    def up
      Board.new(columns.collect(&:pull).collect(&:values).transpose)
    end

    def down
      Board.new(columns.collect(&:push).collect(&:values).transpose)
    end

    def left
      Board.new(rows.collect(&:pull).collect(&:values))
    end

    def right
      Board.new(rows.collect(&:push).collect(&:values))
    end
  end
end