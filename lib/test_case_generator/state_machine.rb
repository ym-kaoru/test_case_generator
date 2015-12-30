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

  class StateMachineContext
    def initialize(attrs={})
      @attrs = attrs

      @state_list = []
      @path_list = []
      @start_state = nil
    end

    def add_state(name, options={})
      ctx = State.new(name, options)
      @state_list << ctx
    end

    def add_path(src_state, dest_state, options={})
      ctx = Path.new(src_state, dest_state, options)
      @path_list << ctx
    end

    def start_state
      if @start_state.nil?
        @state_list[0]
      else
        @state_list.find{ |state| state.name == @start_state }
      end
    end

    def items
      out_items = []
      _items! out_items, start_state
      out_items

      p out_items
    end

    def _items!(out_items, state)
      return if state.nil?

      Utils.concat! out_items, state.items

      tmp_list0 = []
      @path_list.find_all{|path| path.src_state == state.name}.each do |path|
        tmp_list = []
        Utils.concat! tmp_list, path.items
        _items! tmp_list, @state_list.find{ |state| state.name == path.dest_state}
        tmp_list0.concat tmp_list
      end

      Utils.concat! out_items, tmp_list0
    end
  end
end
