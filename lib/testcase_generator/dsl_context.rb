module TestcaseGenerator
  class DSLContext
    attr_reader :children

    def initialize
      @patterns = []
      @before = []
      @after = []
      @children = []
    end

    def <<(events)
      if events.is_a?(String) or events.is_a?(Symbol)
        @patterns << [events]
      else
        @patterns << events
      end
    end

    def before
      yield @before
    end

    def after
      yield @after
    end

    def pattern
      child_context = DSLContext.new
      yield child_context
      @children << child_context
    end

    def seq(&block)
      child_context = DSLContext.new
      child_context.instance_eval &block

      first = true
      tmp = []
      child_context.children.each { |ctx|
        tmp2 = []
        ctx.raw_each { |ptn|
          if first
            tmp2 << ptn
          else
            tmp.each { |x|
              tmp2 << x + ptn
            }
          end
        }

        tmp = tmp2
        first = false
      }

      tmp.each { |x|
        @patterns << x
      }
    end

    def raw_each
      patterns = @patterns.clone

      @children.each { |child_context|
        child_context.raw_each { |ptn|
          patterns << ptn
        }
      }

      patterns.each { |ptn| yield @before + ptn + @after }
    end

    def each
      raw_each { |raw_ptn|
        yield raw_ptn.map { |p|
          p.to_s.split('_').inject([]) { |buffer, e|
            buffer << (buffer.empty? ? e : e.capitalize)
          }.join
        }
      }
    end
  end

  class DSLContextLoader
    def load(filename)
      ctx = DSLContext.new
      ctx.instance_eval(File.read(filename), filename)
      ctx
    end
  end
end
