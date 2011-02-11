# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "log-weasel/version"

Gem::Specification.new do |s|
  s.name        = "log-weasel"
  s.version     = Log::Weasel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alon Salant"]
  s.email       = ["alon@salant.org"]
  s.homepage    = ""
  s.summary     = %q{Instrument Rails and Resque with shared transaction IDs so that you trace execution across instances.}
  s.description = %q{Instrument Rails and Resque with shared transaction IDs so that you trace execution across instances.}

  s.rubyforge_project = "log-weasel"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
