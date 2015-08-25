require 'test_case_generator/dsl_context'
require 'test_case_generator/indented_writer'

module TestCaseGenerator
  class GeneratorPython
    def can_handle?(source_fn)
      File.extname(source_fn).eql? '.py'
    end
  end
end
