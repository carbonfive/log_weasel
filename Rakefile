require 'bundler'
Bundler.setup

require 'rspec'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

$: << File.join(File.dirname(__FILE__),'lib')
require 'stitch_fix/y/tasks'

include Rake::DSL

gemspec = eval(File.read('stitchfix-log_weasel.gemspec'))
Gem::PackageTask.new(gemspec) {}
StitchFix::Y::ReleaseTask.for_rubygems(gemspec)
StitchFix::Y::VersionTask.for_rubygems(gemspec)

task :default => :spec
