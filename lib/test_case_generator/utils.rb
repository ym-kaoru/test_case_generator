module TestCaseGenerator
  class Utils
    def self.make_method_name(label)
      label.to_s.split('_').inject([]) do |buffer, e|
        buffer << (buffer.empty? ? e : e.capitalize)
      end.join
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
  end
end
