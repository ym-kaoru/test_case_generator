module TestcaseGenerator
  class DSLContext
    attr_reader :pattern

    def initialize
      @pattern = Array.new
    end

    def testcase
      yield self
    end

    def <<(event)
      @pattern << event
    end
  end

  class DSLContextLoader
    def load(filename)
      ctx = DSLContext.new
      ctx.instance_eval(File.read(filename), filename)
      ctx
    end
  end
end
