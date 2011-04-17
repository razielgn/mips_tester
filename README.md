# MIPS Tester
MIPS Tester is a simple class that provides the ability to mass test MIPS assemblies.
It relies on MARS (it's ugly I know, but SPIM's cli doesn't work with automated inputs).

## Installation & Prerequisites

* Install Ruby 1.9 (via RVM or natively)

		$> gem install rvm
		$> rvm install 1.9.2
		$> rvm use 1.9.2

* Install MIPS Tester:

		$> gem install mips_tester

* Install the Java Runtime

* Download [MARS](http://courses.missouristate.edu/KenVollmar/MARS/)
	Put it somewhere handy, the path will be requested at runtime!

## Getting Started: Test an empty program

		$> touch test.asm
		$> irb
		$irb :001> require 'mips_tester'
		$irb :002> tester = MIPSTester::MIPS.new :mars_path => "/Applications/MARS_4_1.jar"
		$irb :003> tester.run "test.asm" do |registers, expected|
		$irb :004>		registers.merge! {:s0 => 0x01, :s1 => 0x45}
		$irb :005>		expected.merge! {:s0 => 0x01, :s1 => 0x45}
		$irb :006> end
			=> true
					
## TO-DOs
* Better failed messages