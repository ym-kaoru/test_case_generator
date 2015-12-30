require 'test_case_generator/utils'

module TestCaseGenerator
  class Path
    attr_reader :src_state, :dest_state

    def initialize(src_state, dest_state, attrs={})
      @src_state = src_state
      @dest_state = dest_state
      @attrs = attrs
    end

    def items
      @attrs[:items] || []
    end
  end

  class State
    attr_reader :name

    def initialize(name, attrs={})
      @name = name
      @attrs = attrs
    end

    def items
      @attrs[:items] || []
    end
  end

  class Fork
    attr_reader :state

    def initialize(state, attrs={})
      @state = state
      @attrs = attrs
    end

    def items
      @attrs[:items] || []
    end

    # def join
    #   @attrs[:join]
    # end
  end

  class StateMachineContext
    def initialize(attrs={})
      @attrs = attrs

      @state_list = []
      @path_list = []
      @fork_list = []
      @start_state = attrs[:start_state]
      @reject_block = nil
      @filter_block = nil
    end

    def add_state(name, options={})
      ctx = State.new(name, options)
      @state_list << ctx
    end

    def add_path(src_state, dest_state, options={})
      ctx = Path.new(src_state, dest_state, options)
      @path_list << ctx
    end

    def reject(&block)
      @reject_block = block
    end

    def filter(&block)
      @filter_block = block
    end

    def fork(state, options={})
      @fork_list << Fork.new(state, options)
    end

    def start_state
      if @start_state.nil?
        @state_list[0]
      else
        @state_list.find{ |state| state.name == @start_state }
      end
    end

    def items(options={})
      out_items = []
      counter = {}
      _items! out_items, counter, start_state, options
      out_items.uniq!
      out_items.reject! &(@reject_block) unless @reject_block.nil?
      out_items.keep_if &(@filter_block) unless @filter_block.nil?

      p out_items
      out_items
    end

    def _items!(out_items, counter, state, options={})
      return if state.nil?

      count = counter[state.name] || 0
      count += 1
      counter[state.name] = count

      return if count > (options[:limit] || 2)

      Utils.concat! out_items, state.items

      tmp_list0 = []
      @path_list.find_all{|path| path.src_state == state.name}.each do |path|
        tmp_list = []
        Utils.concat! tmp_list, path.items
        _items! tmp_list, counter.clone, @state_list.find{ |s| s.name == path.dest_state}
        tmp_list0.concat tmp_list
      end

      @fork_list.find_all{|fork| fork.state == state.name}.each do |fork|
        Utils.para! tmp_list0, fork.items
      end

      Utils.concat! out_items, tmp_list0
    end
  end
end
