# coding: utf-8

require 'thor'
require 'test_case_generator/dsl_context'
require 'test_case_generator/generator_objective_c'

module TestCaseGenerator
  class CLI < Thor
    desc 'Injects testcase', 'Injects testcase into source file '
    def hello(testcase_fn, source_fn)
      puts "Injects #{testcase_fn} into #{source_fn}"

      loader = TestCaseGenerator::DSLContextLoader.new
      ctx = loader.load testcase_fn
      gen = TestCaseGenerator::GeneratorObjectiveC.new
      gen.write_header ctx, File.join(File.dirname(source_fn), File.basename(source_fn, File.extname(source_fn)) + 'Generated.h')
      gen.write_source ctx, source_fn
    end
  end
end
