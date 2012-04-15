require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

desc "run beagle tests"
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

desc "sample run"
task :sample_run do
  require 'test/examples/avatar_creator'
  generate_sample_run!
end