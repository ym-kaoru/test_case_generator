require 'test_case_generator/dsl_context'
require 'test_case_generator/indented_writer'

module TestCaseGenerator
  class GeneratorJava
    def can_handle?(source_fn)
      File.extname(source_fn).eql? '.java'
    end

    def write(ctx, source_fn)
      write_interface ctx, File.join(File.dirname(source_fn), File.basename(source_fn, File.extname(source_fn)) + 'Generated.java')
      write_source ctx, source_fn
    end

    def write_interface(dsl_context, header_fn)
      interface_name = File.basename(header_fn, File.extname(header_fn))
      tmp_fn = header_fn + '.tmp'
      File.open(tmp_fn, 'w') do |f|
        writer = IndentedWriter.new f

        writer.blank
        writer.puts '//'
        writer.blank
        writer.puts "public interface #{interface_name} {"

        writer.block_indent '    ' do
          dsl_context.labels.each do |label|
            method_name = label
            writer.puts "void #{method_name}();"
          end
        end

        writer.puts '}'
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
          writer.block_indent '    ' do
            writer.blank
            writer.puts '@Test'
            writer.puts "public void test_#{method_name}() {"

            pattern.each do |ptn|
              writer.block_indent '    ' do
                writer.puts "#{ptn}();"
              end
            end

            writer.puts '}'
          end
        end

        writer.blank
        writer.puts '@end'
      end

      FileUtils.move tmp_fn, source_fn
    end
  end
end
