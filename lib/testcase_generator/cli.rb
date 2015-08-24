# coding: utf-8

require 'thor'
require 'testcase_generator/dsl_context'
require 'testcase_generator/generator_objective_c'

module TestcaseGenerator
  class CLI < Thor

    desc "Injects testcase", "Injects testcase into source file "
    def hello(testcase_fn, source_fn)
      puts "Injects #{testcase_fn} into #{source_fn}"

      loader = TestcaseGenerator::DSLContextLoader.new
      ctx = loader.load testcase_fn
      gen = TestcaseGenerator::GeneratorObjectiveC.new
      gen.write ctx, source_fn
    end

  end
end
