require 'testcase_generator/dsl_context'

module TestCaseGenerator
  class IndentedWriter
    def initialize(out)
      @out = out
      @indent = []
      @current_indent = ''
    end

    def puts(line)
      @out.puts @current_indent + line
    end

    def blank
      @out.puts
    end

    def indent(txt)
      @indent.push @current_indent
      @current_indent += txt
    end

    def unindent
      @current_indent = @indent.pop
    end

    def block_indent(txt)
      indent txt
      yield
      unindent
    end
  end

  class GeneratorObjectiveC
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
