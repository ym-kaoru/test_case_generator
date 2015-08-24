require 'spec_helper'
require 'testcase_generator/cli'

describe TestcaseGenerator do
  it 'has a version number' do
    expect(TestcaseGenerator::VERSION).not_to be nil
  end

  it 'takes two arguments' do
    cli = TestcaseGenerator::CLI.new
    expect(cli.hello('abc1', 'abc2')).to eq(true)
  end
end
