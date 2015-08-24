require 'testcase_generator/dsl_context'

module TestcaseGenerator
  class IndentedWriter
    def initialize(f)
      @f = f
      @indent = []
      @current_indent = ''
    end

    def puts(line)
      @f.puts @current_indent + line
    end

    def blank
      @f.puts
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
    def write(dsl_context, source_fn)
      tmp_fn = source_fn + '.tmp'
      source = File.open(source_fn).read
      File.open(tmp_fn, 'w') do |f|
        source.each_line do |line|
          f.puts line
          break if line =~ /@@/
        end

        writer = IndentedWriter.new f
        dsl_context.pattern.each do |ptn|
          writer.block_indent '    ' do
            writer.puts ptn.to_s
          end
        end
      end

      FileUtils.move tmp_fn, source_fn
    end
  end
end
