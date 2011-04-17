require './spec_helper.rb'

describe MIPSTester::MIPS do
  let :mips do
    MIPSTester::MIPS.new :mars_path => "/Applications/MARS_4_1.jar"
  end
  
  it 'should work properly with empty file' do
    mips.run "../fixtures/empty.asm" do |regs, exp|
      regs.merge! :s0 => 0x0C, :s1 => 0x3F
      exp.merge! :s0 => 0x0C, :s1 => 0x3F
    end.should == true
  end
end