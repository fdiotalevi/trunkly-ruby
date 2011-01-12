# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "trunkly/version"

Gem::Specification.new do |s|
  s.name        = "trunkly"
  s.version     = Trunkly::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Filippo Diotalevi"]
  s.email       = ["filippo.diotalevi@gmail.com"]
  s.homepage    = "https://github.com/fdiotalevi/trunkly-ruby"
  s.summary     = %q{Ruby Client for Trunk.ly API}
  s.description = %q{A Ruby Client for Trunk.ly API}

  s.add_dependency('json', '>= 1.0.0')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
