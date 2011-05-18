# MIPS Tester
MIPS Tester is a simple class that provides the ability to mass test MIPS assemblies.
It relies on MARS (it's ugly I know, but SPIM's cli doesn't work with automated inputs).

## Installation & Prerequisites

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
	$irb :003> tester.test "test.asm" do
	$irb :004>		set :s0 => 0x01
	$irb :005>		set '0x10010004' => 45
	$irb :006>		expect :s0 => 0x01, :s1 => 0x45
	$irb :007>		verbose! # Optional verbosity!
	$irb :008> end
		=> true
		
## Compatibility
### Tested on
* ruby-1.9.2-p180
* ruby-1.8.7-p330
* rbx-head 1.2.4dev