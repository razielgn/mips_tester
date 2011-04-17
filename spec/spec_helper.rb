$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'mips_tester'

def fixture_path(filename)
  File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
end