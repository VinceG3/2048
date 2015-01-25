module Game2048
  class Loop
    attr_reader :board, :input, :output, :num_times

    def initialize(board: Board.create, input: AiInput, output: ConsoleDisplay, times: 1, sleep: true)
      @board = board
      @input = input
      @output = output
      @num_times = times
      @stats = {}
      @sleep = sleep
    end

    def self.start(input: KeyboardInput, output: ConsoleDisplay, times: 1, sleep: true)
      new(input: input,
          output: output,
          times: times,
          sleep: sleep).start
    end

    def start
      @num_times.times{ main_loop; @board = Board.create }
      output.write_stats(@stats) unless num_times == 1
    end

    def main_loop
      loop do
        sleep(0.2) if @sleep
        output._display(board)
        return :win if board.win?
        return lose(board.largest) if board.lose?
        return :quit if :quit == apply_input(input.get_input(board))
      end
    end

    def lose(largest)
      @stats[:largest] ||= {}
      @stats[:largest][largest] ||= 0
      @stats[:largest][largest] += 1
      @stats[:scores] ||= []
      @stats[:scores] << board.score
      putc "L"
      :lose
    end

    def win
      @stats << :win
      putc "W"
      :win
    end

    def direction(direction)
      unless @board.try(direction)
        @board = @board.send(direction)
        @board = @board.add_value
      end
    end

    def apply_input(symbol)
      case symbol
        when :quit
          return :quit
        when :up, :down, :left, :right
          direction(symbol)
      end
    end
  end
end