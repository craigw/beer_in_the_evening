# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "beer_in_the_evening/version"

Gem::Specification.new do |s|
  s.name        = "beer_in_the_evening"
  s.version     = BeerInTheEvening::VERSION
  s.authors     = ["Craig R Webster"]
  s.email       = ["craig@barkingiguana.com"]
  s.homepage    = ""
  s.summary     = %q{Is it pub time?}
  s.description = %q{Search over the Beer In The Evening site looking for suitable pubs}

  s.rubyforge_project = "beer_in_the_evening"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "nokogiri"
end
