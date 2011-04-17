require 'tempfile'
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
  
    def run(file)
      raise Exception.new("Provide valid file!") if not file or not File.exists? file
    
      regs = {}
      expected = {}
    
      yield regs, expected
    
      asm = Tempfile.new "temp.asm"
      asm.write prep_registers(regs)
      asm.write File.read(file)
      asm.close
    
  #    puts "\nASM (#{asm.path}):\n#{File.read asm.path}"
  
      cmd = "#{["java -jar", @mars_path, regs.keys.join(" "), "nc dec", asm.path].join(" ")}"
    
      puts "\nCMD:#{cmd}\n\n"
    
      a = `#{cmd}`
    
      pp a
      gets
    
      begin
        g = parse_results a
      rescue Exception
        puts "Errors in file:\n#{File.read asm}"
        return nil
      end
    
      asm.unlink
    
      #puts "\nResults:"
      #pp g
      g
    end
  
    private
  
    def parse_results(results)
    
      if results =~ /^Error/
        throw Exception.new "Error in file"
      end
    
      results.split("\n")[1..-1].map do |reg|
        g = reg.strip.split("\t")
        {g[0] => g[1].to_i}
      end
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
  end
end