module Game2048
  class Row < Line
    def self.from_board(board)
      board.values.collect{|row| Row.new(row)}
    end
  end
end