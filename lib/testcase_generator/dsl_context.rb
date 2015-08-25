require 'testcase_generator/utils'

module TestcaseGenerator
  class DSLContext
    attr_reader :children
    attr_reader :labels

    def initialize
      @patterns = []
      @before = []
      @after = []
      @children = []
      @labels = []
    end

    def <<(events)
      if events.is_a?(String) or events.is_a?(Symbol)
        @patterns << [events]
        @labels << events unless @labels.include? events
      else
        @patterns << events
        events.each { |label|
          @labels << label unless @labels.include? label
        }
      end
    end

    def def_labels
      yield @labels
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

      child_context.raw_each { |ptn|
        @patterns << ptn
        ptn.each { |label|
          @labels << label unless @labels.include? label
        }
      }
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
        x.each { |label|
          @labels << label unless @labels.include? label
        }
      }
    end

    def raw_each
      @patterns.each { |ptn| yield @before + ptn + @after }
    end

    def each
      raw_each { |raw_ptn|
        yield raw_ptn.map { |p|
          # p.to_s.split('_').inject([]) { |buffer, e|
          #   buffer << (buffer.empty? ? e : e.capitalize)
          # }.join
          TestcaseGenerator::Utils.make_method_name p
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
