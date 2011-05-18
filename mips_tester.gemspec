# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require 'mips_tester'

Gem::Specification.new do |s|
  s.name = 'mips_tester'
  s.version = MIPSTester::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Federico Ravasio']
  s.email = ['ravasio.federico@gmail.com']
  s.summary = 'Class to test MIPS asm files'
  s.homepage = 'http://github.com/razielgn/mips_tester'
  s.description = s.summary + ". It relies on MARS\' cli, so be sure to download its JAR first."

  s.required_ruby_version = '>= 1.8.7'

  s.add_development_dependency 'rspec', '>= 2.6'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
end
