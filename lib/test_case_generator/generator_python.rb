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
            writer.puts "def test_#{method_name}(self):"

            pattern.each do |ptn|
              writer.block_indent '    ' do
                writer.puts "self.#{ptn}()"
              end
            end
          end
        end

        writer.blank
        writer.block_indent '    ' do
          writer.puts "@classmethod"
          writer.puts "def checkSanity(cls):"
          writer.block_indent '    ' do
            writer.puts "sane = True"
            writer.puts "msg = []"
            writer.puts "for method in [#{dsl_context.labels.map { |m| "'#{m}'" }.join(", ")}]:"
            writer.block_indent '    ' do
              writer.puts "if not hasattr(cls, method):"
              writer.block_indent '    ' do
                writer.puts "msg += ["
                writer.block_indent '    ' do
                  writer.puts "'    def %s(self):' % method,"
                  writer.puts "'        pass',"
                  writer.puts "'',"
                end
                writer.puts "]"
                writer.puts "sane = False"
              end
            end

            writer.blank
            writer.puts "if not sane:"
            writer.block_indent '    ' do
              writer.puts "print cls.__name__ + ' must implement following method(s):'"
              writer.puts "print"
              writer.puts "print \"\\n\".join(msg)"
              writer.puts "raise SystemExit(1)"
            end
          end
        end

        writer.blank
        writer.blank
        writer.puts "if __name__ == '__main__':"
        writer.block_indent '    ' do
          writer.puts "CommandLineArgumentsTestCase.checkSanity()"
          writer.puts "unittest.main()"
        end
      end

      FileUtils.move tmp_fn, source_fn
    end
  end
end
