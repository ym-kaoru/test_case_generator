module TestcaseGenerator
  class Utils
    def self.make_method_name(label)
      label.to_s.split('_').inject([]) { |buffer, e|
        buffer << (buffer.empty? ? e : e.capitalize)
      }.join
    end
  end
end
