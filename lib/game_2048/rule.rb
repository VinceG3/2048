module Game2048
  class Rule
    attr_reader :array

    def initialize(line)
      @array = line.is_a?(Array) ? line : line.values
    end

    def self.apply(array)
      new(array).apply
    end

    def dry
      array.delete_if(&:zero?)
    end

    def has_four?
      raise if array.length > 4
      array.length == 4
    end

    def shift_zeroes
      return if has_four?
      array.unshift(0) until has_four?
    end

    def compare(target)
      if array[target - 1] == array[target]
        array[target] = array[target] * 2
        array[target - 1] = 0
        return true
      end
      return false
    end

    def compare_last
      compare 3
    end

    def compare_first
      compare 1
    end

    def compare_middle
      compare 2
    end

    def dry_shift
      dry; shift_zeroes
    end

    def apply
      dry_shift
      if compare_last
        compare_first
      else
        compare_first unless compare_middle
      end
      dry_shift
      return array
    end
  end
end