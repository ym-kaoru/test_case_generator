require 'spec_helper'

describe TestCaseGenerator::DSLContext do
  before(:each) do
    @ctx = TestCaseGenerator::DSLContext.new
  end

  describe 'operator<<' do
    it 'A symbol should be converted to a string' do
      @ctx << :test
      counter = 0
      @ctx.each do |x|
        expect(x.join).to be == 'test'
        counter += 1
      end
      expect(counter).to be == 1
    end

    it 'A string should be a string' do
      @ctx << 'test'
      counter = 0
      @ctx.each do |x|
        expect(x.join).to be == 'test'
        counter += 1
      end
      expect(counter).to be == 1
    end

    it 'An array should be acceptable' do
      @ctx << [:test1, :test2]
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2'
    end

    it 'Two array should be acceptable' do
      @ctx << [:test1, :test2]
      @ctx << [:test3, :test4]
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2|test3,test4'
    end

    it 'The combination of an array and a string should be acceptable' do
      @ctx << [:test1, :test2]
      @ctx << 'test3'
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2|test3'
    end

    it 'A snake_case symbol should be converted to a CamelCase string' do
      @ctx << :this_is_a_pen
      counter = 0
      @ctx.each do |x|
        expect(x.join).to be == 'thisIsAPen'
        counter += 1
      end
      expect(counter).to be == 1
    end

    it 'A snake_case string should be converted to a CamelCase string' do
      @ctx << 'this_is_a_pen'
      counter = 0
      @ctx.each do |x|
        expect(x.join).to be == 'thisIsAPen'
        counter += 1
      end
      expect(counter).to be == 1
    end
  end

  describe 'before and after block' do
    it 'The before block should be placed before the body' do
      @ctx << [:test1, :test2]
      @ctx.before do |items|
        items << :test3
        items << :test4
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test3,test4,test1,test2'
    end

    it 'The after block should be placed after the body' do
      @ctx << [:test1, :test2]
      @ctx.after do |items|
        items << :test3
        items << :test4
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2,test3,test4'
    end

    it 'Both the before block and the after block should be acceptable at the same time' do
      @ctx.after do |items|
        items << :test5
        items << :test6
      end
      @ctx << [:test3, :test4]
      @ctx.before do |items|
        items << :test1
        items << :test2
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2,test3,test4,test5,test6'
    end
  end

  describe 'The choice block' do
    it 'A choice block is acceptable' do
      @ctx.choice do |items|
        items << :test
      end
      counter = 0
      @ctx.each do |x|
        expect(x.join).to be == 'test'
        counter += 1
      end
      expect(counter).to be == 1
    end

    it 'An array in the choice block is acceptable' do
      @ctx.choice do |items|
        items << [:test1, :test2]
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2'
    end

    it 'Multiple choice block is acceptable' do
      @ctx.choice do |items|
        items << [:test1, :test2]
      end
      @ctx.choice do |items|
        items << [:test3, :test4]
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2|test3,test4'
    end
  end

  describe 'The concat block' do
    it 'A Concat block is acceptable' do
      @ctx.concat do
        choice do |items|
          items << [:test1, :test2]
        end
        choice do |items|
          items << [:test3, :test4]
        end
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2,test3,test4'
    end

    it 'A concat should be serial combination of arrays'do
      @ctx.concat do
        choice do |items|
          items << :test1
          items << :test2
        end
        choice do |items|
          items << :test3
          items << :test4
        end
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test3|test2,test3|test1,test4|test2,test4'
    end
  end

  describe 'The parallel block' do
    it 'A parallel block is acceptable' do
      @ctx.parallel do
        choice do |items|
          items << [:test1, :test2]
        end
        choice do |items|
          items << :ev
        end
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2,ev|test1,ev,test2|ev,test1,test2'
    end

    it 'A parallel block 2' do
      @ctx.parallel do
        choice do |items|
          items << [:test1, :test2]
        end
        choice do |items|
          items << [:test3, :test4]
        end
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'test1,test2,test3,test4|test1,test3,test2,test4|test1,test3,test4,test2|test3,test1,test2,test4|test3,test1,test4,test2|test3,test4,test1,test2'
    end

    it 'A parallel block with before and after block' do
      @ctx.before do |items|
        items << :before
      end
      @ctx.after do |items|
        items << :after
      end
      @ctx.parallel do
        choice do |items|
          items << [:test1, :test2]
        end
        choice do |items|
          items << :ev
        end
      end
      check = []
      @ctx.each do |x|
        check << x.join(',')
      end
      expect(check.join('|')).to be == 'before,test1,test2,ev,after|before,test1,ev,test2,after|before,ev,test1,test2,after'
    end
  end
end
