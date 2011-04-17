require 'spec_helper'

describe MIPSTester::MIPS do
  let :mips do
    MIPSTester::MIPS.new :mars_path => "/Applications/MARS_4_1.jar"
  end
  
  it 'should work properly with an empty file' do
    mips.run fixture_path("empty.asm") do
      register :s0 => 0x0C, :s1 => 0x3F
      register :s2 => 0x34
      expected :s0 => 0x0C, :s1 => 0x3F
      expected :s2 => 0x34
    end.should be_true
  end
end