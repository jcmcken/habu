module Habu
  class InvalidInstruction < RuntimeError; end
  class VM
    INSTRUCTIONS = {
      0x00 => :literal,
      0x01 => :add,
      0x02 => :subtract,
      0x03 => :multiply,
      0x04 => :divide,
    }

    attr_reader :stack

    def initialize
      @stack = Stack.new
      @store = 0
    end

    def self.execute(bytes)
      VM.new.execute(bytes)
    end

    def execute(bytes)
      bytes.each do |byte|
        if @store > 0
          @store =- 1
          @stack.push(byte)
          next
        end
        LOG.debug("stack: #{@stack.inspect}")
        execute_instruction(byte)
      end
      LOG.debug("stack: #{@stack.inspect}")
      @stack.dup
    end

    private

    def store(number = 1)
      @store = number
    end

    def instruction_literal
      store(1)
    end

    def instruction_add
      @stack.push(@stack.pop + @stack.pop)
    end

    def instruction_subtract
      @stack.push(@stack.pop - @stack.pop)
    end

    def instruction_multiply
      @stack.push(@stack.pop * @stack.pop)
    end

    def instruction_divide
      @stack.push(@stack.pop.to_f / @stack.pop)
    end

    def execute_instruction(byte)
      method = get_instruction_method(byte)
      LOG.debug("executing #{method.upcase}")
      send(method)
    end

    def get_instruction_method(byte)
      begin
        'instruction_' + VM::INSTRUCTIONS.fetch(byte).to_s
      rescue IndexError
        raise InvalidInstruction.new(byte.inspect)
      end
    end
  end
end
