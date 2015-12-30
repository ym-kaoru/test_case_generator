require 'test_case_generator/utils'
require 'test_case_generator/state_machine'

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
              (0..x.length + ptn.length - 1).to_a.combination(x.length) do |index_arr|
                x_index = 0
                ptn_index = 0
                tmp2 << (0..x.length + ptn.length - 1).map do |i|
                  if index_arr.include?(i)
                    ret = x[x_index]
                    x_index += 1
                  else
                    ret = ptn[ptn_index]
                    ptn_index += 1
                  end

                  ret
                end
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
    alias_method :para, :parallel

    def def_state_machine(options={}, &block)
      ctx = StateMachineContext.new(options)
      ctx.instance_eval &block if block_given?
      ctx
    end

    def state_machine(options={}, &block)
      ctx = def_state_machine options, &block

      ctx.items.each do |x|
        @patterns << x
        x.each do |label|
          @labels << label unless @labels.include? label
        end
      end
      # @patterns.concat ctx.items
    end

    def add_async_events(src_items, options={})
      out_items = []

      src_items.each do |pattern1|
        idx_from = options[:from].nil? ? nil : pattern1.find_index{|item| item==options[:from]}
        if idx_from.nil?
          out_items << pattern1
          next
        end

        pattern2 = pattern1[idx_from + 1 ... pattern1.size]
        idx_to = options[:to].nil? ? nil : pattern2.find_index{|item| item==options[:to]}

        tmp_items = idx_to.nil? ? [pattern2] : [pattern2[0 ... idx_to]]
        Utils.para! tmp_items, options[:items]

        out_items.concat tmp_items.map{ |ptn| pattern1[0 .. idx_from] + ptn + (idx_to.nil? ? pattern2 : pattern2[idx_to ... pattern2.size]) }
      end

      out_items.uniq
    end

    def add_async_events!(src_items, options={})
      tmp_items = add_async_events(src_items, options)

      src_items.clear
      src_items.concat tmp_items
      src_items
    end

    def add_patterns(patterns)
      @patterns.concat patterns
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
