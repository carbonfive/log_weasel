# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "stitch_fix/log_weasel/version"

Gem::Specification.new do |s|
  s.name        = "stitchfix-log_weasel"
  s.version     = StitchFix::LogWeasel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alon Salant", "Brett Fishman"]
  s.email       = ["alon@salant.org", "brettfishman@gmail.com"]
  s.homepage    = "http://github.com/stitchfix/log_weasel"
  s.summary     = "stitchfix-log_weasel-#{StitchFix::LogWeasel::VERSION}"
  s.description = %q{Instrument Rails and Resque with shared transaction IDs so that you trace execution across instances.}

  s.add_development_dependency('airbrake')
  s.add_development_dependency('gemfury')
  s.add_development_dependency('logger')
  s.add_development_dependency('mocha')
  s.add_development_dependency('pwwka')
  s.add_development_dependency('rake')
  s.add_development_dependency('resque')
  s.add_development_dependency('resque-scheduler')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec_junit_formatter')
  s.add_development_dependency('stitchfix-y')
  s.add_development_dependency('combustion', '=1.1.2')

  s.add_dependency('activesupport')
  s.add_dependency('ulid')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
