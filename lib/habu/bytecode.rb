module Habu
  class BytecodeFile
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def self.read(filename)
      BytecodeFile.new(filename).read
    end

    def read
      raw = File.open(@filename, 'rb').read.unpack('C*')
      Bytecode.new(raw)
    end

    def write(bytecode)
      fd = File.open(@filename, 'wb')
      fd.write(bytecode.raw.pack('C*'))
      fd.close
    end
  end

  class Bytecode
    attr_reader :position, :length, :raw

    SEEK_SET = 0x00
    SEEK_CUR = 0x01
    SEEK_END = 0x02

    def initialize(raw)
      @raw = raw
      @position = 0
      @length = @raw.length
    end

    def get(amount = 1)
      data = @raw[@position..@position+amount-1]
      step amount

      return nil if data.empty?

      data.length == 1 ? data[0] : data
    end

    def step(amount = 1)
      seek(amount, Bytecode::SEEK_CUR)
    end

    def seek(amount, whence = Bytecode::SEEK_SET)
      case whence
      when Bytecode::SEEK_CUR, Bytecode::SEEK_END
        position = whence == Bytecode::SEEK_END ? @length : @position 
        if amount > 0
          extremum = @length
          selector = 'min'
        else
          extremum = 0
          selector = 'max'
        end
        @position = [position + amount, extremum].send(selector)
      when Bytecode::SEEK_SET
        @position = amount
      else
        raise ArgumentError.new('invalid seek')
      end
    end
  end
end
