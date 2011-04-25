require 'spec_helper'
include MIPSTester

describe MIPS do
  context 'passing wrong parameters' do
    it 'should raise exception if not valid MARS path is given' do
      expect do
        MIPS.new :mars_path => '/tmp/MARS.jar'
      end.to raise_error(::MIPSMarsError)
    end
    
    it 'should raise exception if not valid file path is given' do
      mips = MIPS.new :mars_path => "/Applications/MARS_4_1.jar"
      expect do
        mips.test fixture_path("non-existing.asm") {}
      end.to raise_error(::MIPSFileError)
    end
    
    it 'should raise exception if no block is given on test method' do
      mips = MIPS.new :mars_path => "/Applications/MARS_4_1.jar"
      expect do
        mips.test fixture_path("empty.asm")
      end.to raise_error(::MIPSInvalidBlockError)
    end
  end
  
  
  context 'work on empty file' do
    let :mips do
      MIPS.new :mars_path => "/Applications/MARS_4_1.jar"
    end
    
    it 'should expect given register values' do
      mips.test fixture_path("empty.asm") do
        set :s0 => 0x0C, :s1 => 0x3F
        expect :s0 => 0x0C, :s1 => 0x3F
      end.should be_true
    end
    
    it 'should fail with expected results different from set results' do
      mips.test fixture_path("empty.asm") do
        set :s0 => 0x0D, :s1 => 0x3E
        expect :s0 => 0x0C, :s1 => 0x3F
      end.should be_false
    end
    
    it 'should expect given memory address values' do
      mips.test fixture_path("empty.asm") do
        set '0x10010000' => 45, '0x10010010' => 32, '0x10010020' => 0xFF
        expect '0x10010000' => 45, '0x10010010' => 32, '0x10010020' => 0xFF
      end.should be_true
    end
    
    it 'should expect mixed parameters' do
      mips.test fixture_path("empty.asm") do
        set '0x10010000' => 45, :s0 => 32
        expect '0x10010000' => 45, :s0 => 32
      end.should be_true
    end
  end
end