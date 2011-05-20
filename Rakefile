require 'bundler'
Bundler::GemHelper.install_tasks

require 'yard'
require 'rspec/core/rake_task'

task :default => [:spec]

desc "run spec tests"
RSpec::Core::RakeTask.new('test') do |t|
  t.pattern = 'spec/*_spec.rb'
end

desc 'Generate documentation'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/*.rb', '-', 'LICENSE']
  t.options = ['--main', 'README.md', '--no-private']
end