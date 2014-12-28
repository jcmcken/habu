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

    def initialize(raw)
      @raw = raw
      @position = 0
      @length = @raw.length
    end

    def get(amount = 1)
      data = @raw[@position..@position+amount-1]
      @position = [@position + amount, @length].min

      return nil if data.empty?

      data.length == 1 ? data[0] : data
    end

    def seek(index)
      @position = index
    end
  end
end
