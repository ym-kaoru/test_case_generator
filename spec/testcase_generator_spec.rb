require 'spec_helper'
require 'testcase_generator/cli'

describe TestCaseGenerator do
  it 'has a version number' do
    expect(TestCaseGenerator::VERSION).not_to be nil
  end

  it 'takes two arguments' do
    cli = TestCaseGenerator::CLI.new
    expect(cli.hello('abc1', 'abc2')).to eq(true)
  end
end
