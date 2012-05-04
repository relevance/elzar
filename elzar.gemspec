# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "elzar/version"

Gem::Specification.new do |s|
  s.name        = "elzar"
  s.version     = Elzar::VERSION
  s.homepage    = "http://github.com/relevance/elzar"
  s.authors     = ["Alex Redington", "Gabriel Horner"]
  s.email       = ["alex.redington@thinkrelevance.com"]
  s.summary     = %q{Chef cookbooks for Rails}
  s.description = %q{Provides Chef cookbooks for a production Rails environment. Also supports Chef-erizing a Rails app.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency 'rake', '~> 0.9.2.2'
  s.add_development_dependency 'rspec'
end
