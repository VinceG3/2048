require 'io/console'
require 'pry'
require './lib/game_2048'

module Game2048
  def self.play(input = ARGV.first)
    sleep = true
    case input
    when "ai"
      ginput = AiInput
      output = ConsoleDisplay
      times = 1
    when "aibench"
      ginput = AiInput
      output = NoOutput
      times = 50
      sleep = false
    else 
      ginput = KeyboardInput
      output = ConsoleDisplay
      times = 1
      sleep = false
    end
    Loop.start(input: ginput, output: output, times: times, sleep: sleep)
  end
end

Game2048::play if __FILE__ == $0