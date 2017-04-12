require 'bundler'
Bundler.setup

require 'rspec'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

$: << File.join(File.dirname(__FILE__),'lib')
require 'stitch_fix/y/tasks'

include Rake::DSL

gemspec = eval(File.read('log_weasel.gemspec'))
Gem::PackageTask.new(gemspec) {}
RSpec::Core::RakeTask.new(:spec)
StitchFix::Y::ReleaseTask.for_rubygems(gemspec)
StitchFix::Y::VersionTask.for_rubygems(gemspec)

task :default => :spec