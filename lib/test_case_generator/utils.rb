module TestCaseGenerator
  class Utils
    def self.make_method_name(label)
      label.to_s.split('_').inject([]) do |buffer, e|
        buffer << (buffer.empty? ? e : e.capitalize)
      end.join
    end

    def self.concat(*args)
      out_items = []

      args.each do |arg|
        self.concat! out_items, arg
      end

      out_items
    end

    def self.concat!(out_items, other_list)
      if out_items.size == 0
        out_items.concat other_list
      else
        return out_items if other_list.empty?

        tmp_list = []
        out_items.each do |item1|
          other_list.each do |item2|
            tmp_list << item1 + item2
          end
        end

        out_items.clear
        out_items.concat tmp_list
      end

      out_items
    end

    def self.para(*args)
      out_items = []

      args.each do |arg|
        self.para! out_items, arg
      end

      out_items
    end

    def self.para!(out_items, other_list)
      if out_items.size == 0
        out_items.concat other_list
      else
        return out_items if other_list.empty?
        tmp_list = []
        out_items.each do |item1|
          other_list.each do |item2|
            (0...(item1.size + item2.size)).to_a.combination(item1.size) do |index_arr|
              idx_item1 = 0
              idx_item2 = 0
              tmp_list << (0...(item1.size + item2.size)).to_a.map do |x|
                if index_arr.include?(x)
                  picked = item1[idx_item1]
                  idx_item1 += 1
                else
                  picked = item2[idx_item2]
                  idx_item2 += 1
                end

                picked
              end
            end
          end
        end

        out_items.clear
        out_items.concat tmp_list
      end

      out_items
    end
  end
end
