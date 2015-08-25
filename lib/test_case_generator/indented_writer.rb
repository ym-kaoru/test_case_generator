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
end
