module Habu
  class EmptyStack < RuntimeError; end
  class Stack
    def initialize
      @data = Array.new
    end
    
    def push(item)
      @data.push(item)
    end

    def pop
      value = @data.pop
      raise EmptyStack if value.nil?
      value
    end

    def inspect
      @data.inspect
    end
  end
end
