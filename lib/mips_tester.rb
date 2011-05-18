require 'tempfile' unless defined? Tempfile

# Main MIPSTester module
module MIPSTester
  # Library version
  VERSION = "0.1.3"
  
  # MIPSFileError Exception, raised when test file is not valid or non-existent
  class MIPSFileError < Exception; end
  
  # MIPSInvalidBlockError Exception, raised when no block is given to test method
  class MIPSInvalidBlockError < Exception; end
  
  # MIPSMarsError Exception, raised when MARS installation path is not valid.
  class MIPSMarsError < Exception; end
  
  # Main MIPS tester class.
  # It provides the methods to test MIPS ASMs files
  class MIPS
    # Register validation
    REGISTER_REGEX = /^(at|v[01]|a[0-3]|s[0-7]|t\d|[2-9]|1[0-9]|2[0-5])$/
    
    # Memory address validation
    ADDRESS_REGEX = /^0x[\da-f]{8}$/
    
    # MARS jar path
    attr_reader :mars_path
    
    # Create a new MIPSTester::MIPS object
    #
    # @example
    #   MIPSTester::MIPS.new :mars_path => 'path/to/mars.jar'
    #
    # @return [MIPSTester::MIPS] The MIPSTester::MIPS object 
    def initialize(params = {})
      @mars_path = params.delete(:mars_path)
      raise MIPSMarsError.new("Provide valid Mars jar.") if not @mars_path or not File.exists? @mars_path
    end
  
    # Run a given file in the emulator. *A provided block is mandatory*, with starter registers
    # and expected values.
    # A simple DSL is provided:
    # * set [Hash] => set initial registers or memory addresses
    # * expect [Hash] => expect values of registers or memory addresses
    # * verbose! => optional, if given prints on STDOUT set registers and expected ones
    #
    # @example
    #   test "file.asm" do
    #     set :s1 => 6, '0x10010000' => 0xFF
    #     expect :s5 => 6
    #     verbose!
    #   end
    #
    # @param file [String] The path to the file to run
    # @param block The block to provide info on what to test
    #
    # @return [Boolean] True if the test went well, False if not.
    def test(file, &block)
      raise MIPSFileError.new("Provide valid file.") if not file or not File.exists? file
      raise MIPSInvalidBlockError.new("Provide block.") if not block
    
      reset!
  
      instance_eval(&block)
    
      asm = Tempfile.new "temp.asm"
      asm.write prep_params if block
      asm.write File.read(file)
      asm.close
    
      cli = `#{["java -jar",
                @mars_path,
                @exp.empty? ? "" : @exp.keys.join(" "), 
                @addresses.empty? ? "" : [@addresses.keys.min, @addresses.keys.max].join("-"),
                "nc dec",
                asm.path].join(" ")}`
      
      begin
        results = parse_results cli
        
        puts "Expected:\n#{@exp}\nResults:\n#{results}" if @verbose
        
        return compare_hashes(@exp, results)
      rescue Exception => ex
        raise MIPSFileError.new ex.message.gsub(asm.path, File.basename(file)).split("\n")[0..1].join("\n")
      ensure
        asm.unlink
      end
    end
  
    private
    
    def verbose!; @verbose = true; end
    
    def set hash
      hash.each_pair do |key, value|
        case key.to_s
          when REGISTER_REGEX then @regs.merge! key => value
          when ADDRESS_REGEX then @addresses.merge! key => value
          else puts "Warning: #{key.inspect} not recognized as register or memory address. Discarded."
        end
      end
    end
    
    def expect hash; @exp.merge! hash; end
    
    def reset!
      @regs = {}; @addresses = {}; @exp = {}; @verbose = false
    end
  
    def parse_results(results)
      raise Exception.new "Error in given file!\nReason: #{results}\n\n" if results =~ /^Error/
      
      out = {}
      
      results.split("\n")[1..-1].each do |reg|
        key, value = reg.strip.split("\t")
        
        if key =~ /^Mem/
          out.merge! key[4..-2] => value.to_i
        else
          out.merge! key[1..-1] => value.to_i
        end
      end
      
      out
    end
  
    def prep_params
      out = ""
      @regs.each_pair {|key, value| out << "li\t\t$#{key}, #{value}\n" }
      @addresses.each_pair do |key, value|
        out << "li\t\t$t0, #{key}\n"
        out << "li\t\t$t1, 0x#{value.to_s(16)}\n"
        out << "sb\t\t$t1, ($t0)\n"
      end
      
      out
    end
    
    def compare_hashes(first, second)
      first.each_pair do |key, value|
        return false unless second[key.to_s] == value
      end
      
      true
    end
  end
end