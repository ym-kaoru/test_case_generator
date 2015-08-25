require 'test_case_generator/dsl_context'
require 'test_case_generator/indented_writer'

module TestCaseGenerator
  class GeneratorFactory
    def initialize
      @generators = []
    end

    def register(generator)
      @generators << generator
    end

    def query(source_fn)
      @generators.each do |g|
        if g.can_handle? source_fn
          return g
        end
      end
    end
  end
end
