module Game2048
  class Line
    attr_reader :values
    def initialize(*values)
      @values = values.flatten
      @values = [0, 0, 0, 0] if @values.length.zero?
      raise if invalid?
    end

    def power_of_two?(value)
      value & (value - 1) == 0
    end

    def invalid?
      return true if @values.length != 4
      return true if @values.select{|val| power_of_two?(val) }.size < 4
      return false
    end

    def ==(other)
      other.values == values      
    end

    def inspect
      "<#{self.class.name.gsub(/^.*::/, '')}: #{values.join(', ')}>"
    end

    def [](index)
      values[index]
    end

    def set(index, value)
      v = values.clone
      v[index] = value
      return v
    end

    def push
      @values = Rule.apply(values)
      return self
    end

    def pull
      @values = Rule.apply(values.reverse).reverse
      return self
    end
  end
end