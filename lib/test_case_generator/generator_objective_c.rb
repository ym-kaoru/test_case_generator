require 'test_case_generator/dsl_context'
require 'test_case_generator/indented_writer'

module TestCaseGenerator
  class GeneratorObjectiveC
    def can_handle?(source_fn)
      File.extname(source_fn).eql? '.m'
    end

    def write(ctx, source_fn)
      write_skeleton source_fn unless File.exists? source_fn
      write_header ctx, File.join(File.dirname(source_fn), File.basename(source_fn, File.extname(source_fn)) + 'Generated.h')
      write_source ctx, source_fn
    end

    def make_class_name(filename)
      File.basename filename, ".*"
    end

    def write_skeleton(source_fn)
      class_name = make_class_name(source_fn)
      File.open(source_fn, 'w') do |f|
        writer = IndentedWriter.new f
        writer.puts <<EOS
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "#{class_name}Generated.h"
#pragma mark -

@interface #{class_name} : XCTestCase <#{class_name}Generated>
@end

@implementation #{class_name}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

// %%
EOS
      end
    end

    def write_header(dsl_context, header_fn)
      protocol_name = File.basename(header_fn, File.extname(header_fn))
      tmp_fn = header_fn + '.tmp'
      File.open(tmp_fn, 'w') do |f|
        writer = IndentedWriter.new f

        writer.puts '#import <Foundation/Foundation.h>'
        writer.blank
        writer.puts "@protocol #{protocol_name} <NSObject>"

        dsl_context.labels.each do |label|
          method_name = label
          writer.puts "- (void)#{method_name};"
        end

        writer.puts '@end'
      end

      FileUtils.move tmp_fn, header_fn
    end

    def write_source(dsl_context, source_fn)
      tmp_fn = source_fn + '.tmp'
      source = File.open(source_fn).read
      File.open(tmp_fn, 'w') do |f|
        source.each_line do |line|
          f.puts line
          break if line =~ /^\s*\/\/\s*%%\s*$/
        end

        writer = IndentedWriter.new f

        dsl_context.each do |pattern|
          method_name = pattern.join '_'
          writer.blank
          writer.puts "- (void)test_#{method_name} {"

          pattern.each do |ptn|
            writer.block_indent '    ' do
              writer.puts "[self #{ptn}];"
            end
          end

          writer.puts '}'
        end

        writer.blank
        writer.puts '@end'
      end

      FileUtils.move tmp_fn, source_fn
    end
  end
end
