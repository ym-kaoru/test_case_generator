# coding: utf-8

require 'thor'
require 'test_case_generator/dsl_context'
require 'test_case_generator/generator_factory'
require 'test_case_generator/generator_objective_c'
require 'test_case_generator/generator_java'
require 'test_case_generator/generator_php'
require 'test_case_generator/generator_python'
require 'test_case_generator/generator_javascript'

module TestCaseGenerator
  class CLI < Thor
    desc 'inject TEST_CASE TARGET_FILE', 'Injects test-cases into source file '
    def inject(testcase_fn, source_fn)
      puts "Injects #{testcase_fn} into #{source_fn}"

      loader = TestCaseGenerator::DSLContextLoader.new
      ctx = loader.load testcase_fn

      factory = TestCaseGenerator::GeneratorFactory.new
      factory.register TestCaseGenerator::GeneratorObjectiveC.new
      factory.register TestCaseGenerator::GeneratorJava.new
      factory.register TestCaseGenerator::GeneratorPHP.new
      factory.register TestCaseGenerator::GeneratorPython.new
      factory.register TestCaseGenerator::GeneratorJavaScript.new

      gen = factory.query source_fn
      gen.write ctx, source_fn
    end
  end
end
