require 'tempfile' unless defined? Tempfile
require 'pp'

module MIPSTester
  VERSION = "0.0.1"
  
  class MIPS
    REGISTER = /^(at|v[01]|a[0-3]|s[0-7]|t\d|[2-9]|1[0-9]|2[0-5])$/
    ADDRESS = /^(\d{1,10}|0x[\da-f]{1,8}|0b[01]{1,32})$/
  
    def initialize(params = {})
      @mars_path = params.delete(:mars_path)
      raise Exception.new("Provide valid Mars jar!") if not @mars_path or not File.exists? @mars_path
    end
  
    def run(file, &block)
      raise Exception.new("Provide valid file!") if not file or not File.exists? file
      raise Exception.new("Provide block!") if not block
    
      reset!
  
      instance_eval(&block)
    
      asm = Tempfile.new "temp.asm"
      asm.write prep_registers(@regs)
      asm.write File.read(file)
      asm.close
    
      cli = `#{["java -jar", @mars_path, @regs.keys.join(" "), "nc dec", asm.path].join(" ")}`
    
      begin
        results = parse_results cli
        
        if @verbose
          puts "\nExpected:"
          pp @exp
          puts "\nResults:"
          pp results
        end
        
        return compare_hashes(@exp, results)
      rescue Exception => ex
        puts ex.message
        return nil
      ensure
        asm.unlink
      end
    end
  
    private
    
    def verbose!; @verbose = true; end
    def register hash; @regs.merge! hash; end
    def expected hash; @exp.merge! hash; end
    
    def reset!
      @regs = {}; @exp = {}; @verbose = false
    end
  
    def parse_results(results)
      if results =~ /^Error/
        throw Exception.new "Error in file\nReason: #{results}\n\n"
      end
      
      out = {}
      
      results.split("\n")[1..-1].map do |reg|
        g = reg.strip.split("\t")
        out.merge! g[0].gsub("$", "") => g[1].to_i
      end
      
      out
    end
  
    def prep_registers(regs)
      out = ""
      regs.each_pair do |key, value|
        if key =~ REGISTER
          out << "li\t\t$#{key}, #{value}\n"
        elsif key =~ ADDRESS
          out << "li\t\t$t0, #{key}\n"
          out << "li\t\t$t1, 0x#{value.to_s(16)}\n"
          out << "sb\t\t$t1, ($t0)\n"
        end
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