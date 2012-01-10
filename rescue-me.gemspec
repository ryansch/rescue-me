# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rescue_me/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryan Schlesinger"]
  gem.email         = ["ryan@instanceinc.com"]
  gem.summary       = %q{Provides common exception rescue lists}
  gem.description   = %q{Instead of hardcoding lists of exceptions to rescue, put them in one place!}
  gem.homepage      = "http://github.com/ryansch/rescue-me"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rescue-me"
  gem.require_paths = ["lib"]
  gem.version       = RescueMe::VERSION
end
