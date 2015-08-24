# coding: utf-8

require 'thor'

module TestcaseGenerator
  class CLI < Thor
    desc "hello NAME", "say hello to NAME"
    def hello(name1, name2)
      puts "Hello #{name1} #{name2}"
    end
  end
end
