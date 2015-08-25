module TestCaseGenerator
  class Utils
    def self.make_method_name(label)
      label.to_s.split('_').inject([]) do |buffer, e|
        buffer << (buffer.empty? ? e : e.capitalize)
      end.join
    end
  end
end
