require 'test_case_generator/dsl_context'
require 'test_case_generator/indented_writer'

module TestCaseGenerator
  class GeneratorPython
    def can_handle?(source_fn)
      File.extname(source_fn).eql? '.py'
    end

    def write(ctx, source_fn)
      write_source ctx, source_fn
    end

    def write_source(dsl_context, source_fn)
      tmp_fn = source_fn + '.tmp'
      source = File.open(source_fn).read
      File.open(tmp_fn, 'w') do |f|
        source.each_line do |line|
          f.puts line
          break if line =~ /^\s*#\s*%%\s*$/
        end

        writer = IndentedWriter.new f

        dsl_context.each do |pattern|
          method_name = pattern.join '_'
          writer.block_indent '    ' do
            writer.blank
            writer.puts "def test_#{method_name}():"

            pattern.each do |ptn|
              writer.block_indent '    ' do
                writer.puts "#{ptn}()"
              end
            end
          end
        end

        writer.blank
      end

      FileUtils.move tmp_fn, source_fn
    end
  end
end
