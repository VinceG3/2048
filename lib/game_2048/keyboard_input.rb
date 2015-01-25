module Game2048
  class KeyboardInput
    def self.get_input(board)
      return get_symbol(get_char)
    end

    def self.get_symbol(char)
      map(char)
    end

    def self.map(input)
      {
        "q" => :quit,
        "w" => :up,
        "a" => :left,
        "s" => :down,
        "d" => :right,
      }[input]
    end

    def self.get_char
      state = `stty -g`
      `stty raw -echo -icanon isig`
      STDIN.getc.chr
    ensure
      `stty #{state}`
    end
  end
end