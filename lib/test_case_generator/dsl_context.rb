require 'test_case_generator/utils'

module TestCaseGenerator
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
      if events.is_a?(String) || events.is_a?(Symbol)
        @patterns << [events]
        @labels << events unless @labels.include? events
      else
        @patterns << events
        events.each do |label|
          @labels << label unless @labels.include? label
        end
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

      child_context.raw_each do |ptn|
        @patterns << ptn
        ptn.each do |label|
          @labels << label unless @labels.include? label
        end
      end
    end
    alias_method :choice, :pattern

    def concat(&block)
      child_context = DSLContext.new
      child_context.instance_eval &block

      first = true
      tmp = []
      child_context.children.each do |ctx|
        tmp2 = []
        ctx.raw_each do |ptn|
          if first
            tmp2 << ptn
          else
            tmp.each do |x|
              tmp2 << x + ptn
            end
          end
        end

        tmp = tmp2
        first = false
      end

      tmp.each do |x|
        @patterns << x
        x.each do |label|
          @labels << label unless @labels.include? label
        end
      end
    end
    alias_method :seq, :concat

    def parallel(&block)
      child_context = DSLContext.new
      child_context.instance_eval &block

      first = true
      tmp = []
      child_context.children.each do |ctx|
        tmp2 = []
        ctx.raw_each do |ptn|
          if first
            tmp2 << ptn
          else
            tmp.each do |x|
              (0 .. x.length + ptn.length - 1).to_a.combination(x.length) do |index_arr|
                x_index = 0
                ptn_index = 0
                tmp2 << (0 .. x.length + ptn.length - 1).map { |i|
                  if index_arr.include?(i)
                    ret = x[x_index]
                    x_index += 1
                  else
                    ret = ptn[ptn_index]
                    ptn_index += 1
                  end

                  ret
                }
              end
            end
          end
        end

        tmp = tmp2
        first = false
      end

      tmp.each do |x|
        @patterns << x
        x.each do |label|
          @labels << label unless @labels.include? label
        end
      end
    end

    def raw_each
      @patterns.each { |ptn| yield @before + ptn + @after }
    end

    def each
      raw_each do |raw_ptn|
        yield raw_ptn.map { |p|
          # p.to_s.split('_').inject([]) { |buffer, e|
          #   buffer << (buffer.empty? ? e : e.capitalize)
          # }.join
          TestCaseGenerator::Utils.make_method_name p
        }
      end
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
