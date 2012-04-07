# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "morlock/version"

Gem::Specification.new do |s|
  s.name        = "morlock"
  s.version     = Morlock::VERSION
  s.authors     = ["Andrew Cantino & Chris Alvarado-Dryden"]
  s.email       = ["pair+andrew+chris@mavenlink.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "morlock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rr"
  #s.add_runtime_dependency "memcache-client"
end
