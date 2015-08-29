require 'spec_helper'
require 'test_case_generator/cli'

describe TestCaseGenerator do
  it 'has a version number' do
    expect(TestCaseGenerator::VERSION).not_to be nil
  end

  describe 'inject' do
    before(:each) do
      @cli = TestCaseGenerator::CLI.new
      fn = SecureRandom.uuid
      @testcase = "/tmp/#{fn}.testcase"
      @target = "/tmp/#{fn}.m"
      @header = "/tmp/#{fn}Generated.h"

      File.new(@testcase, 'wb').write <<EOS
choice do |t|
  t << :test
end
EOS
    end
    after(:each) do
      File.unlink @testcase
      File.unlink @target
      File.unlink @header
    end
    it 'takes two arguments' do
      expect(@cli.inject(@testcase, @target)).to be == 0
      expect(File.exist?(@target)).to be == true
      expect(File.exist?(@header)).to be == true
    end
  end
end
