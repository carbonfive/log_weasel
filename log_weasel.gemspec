# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "log_weasel/version"

Gem::Specification.new do |s|
  s.name        = "log_weasel"
  s.version     = Log::Weasel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alon Salant"]
  s.email       = ["alon@salant.org"]
  s.homepage    = "http://github.com/carbonfive/log_weasel"
  s.summary     = "log_weasel-#{Log::Weasel::VERSION}"
  s.description = %q{Instrument Rails and Resque with shared transaction IDs so that you trace execution across instances.}

  s.rubyforge_project = "log_weasel"
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('mocha')
  s.add_development_dependency('resque')
  s.add_development_dependency('airbrake')
  s.add_development_dependency('gemfury')

  s.add_dependency('activesupport')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
