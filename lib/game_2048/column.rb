module Game2048
  class Column < Line
    def self.from_board(board)
      board.values.transpose.collect{|column| Column.new(column) }
    end
  end
end