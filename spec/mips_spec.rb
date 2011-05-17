require 'spec_helper'
include MIPSTester

describe MIPS do
  let :mips do
    MIPS.new :mars_path => "/Applications/MARS_4_1.jar"
  end
  
  context 'passing wrong parameters' do
    it 'should raise exception if not valid MARS path is given' do
      expect do
        MIPS.new :mars_path => '/tmp/MARS.jar'
      end.to raise_error(::MIPSMarsError)
    end
    
    it 'should raise exception if not valid file path is given' do
      expect do
        mips.test fixture_path("non-existing.asm")
      end.to raise_error(::MIPSFileError)
    end
    
    it 'should raise exception if no block is given on test method' do
      expect do
        mips.test fixture_path("empty.asm")
      end.to raise_error(::MIPSInvalidBlockError)
    end
    
    it 'should raise exception if file given isn\'t parsable by MARS' do
      expect do
        mips.test fixture_path("invalid_syntax.asm") do
          set t1: 0, t2: 3
          expect t1: 0, t2: 3
        end
      end.to raise_error(::MIPSFileError)
    end
  end
  
  
  context 'work on empty file' do  
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
  
  context 'add.asm' do
    it 'should expect 11 when adding 5 and 6' do
      mips.test fixture_path("add.asm") do
        set :t1 => 5, :t2 => 6
        expect :t0 => 11
      end.should be_true
    end
    
    it 'should expect -9 when adding 18 and -27' do
      mips.test fixture_path("add.asm") do
        set :t1 => 18, :t2 => -27
        expect :t0 => -9
      end.should be_true
    end
  end
end