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

    def initialize
      @stack = Stack.new
      @running_bytecode = nil
    end

    def self.execute(bytes)
      VM.new.execute(bytes)
    end

    def execute(target)
      case target
      when String
        execute_file(target)
      when Bytecode
        execute_bytecode(target)
      end
    end

    def running?
      ! @running_bytecode.nil?
    end

    private

    def execute_file(filename)
      execute_bytecode(BytecodeFile.read(filename))
    end

    def execute_bytecode(bytecode)
      @running_bytecode = bytecode

      loop do
        byte = @running_bytecode.get

        break if byte.nil?

        LOG.debug("stack: #{@stack.inspect}")
        execute_instruction(byte)
      end
      @running_bytecode = nil

      LOG.debug("stack: #{@stack.inspect}")
      @stack.dup
    end


    def instruction_literal
      @stack.push(@running_bytecode.get)
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
