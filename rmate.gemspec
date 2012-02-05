# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rmate/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["OZAWA Sakuro"]
  gem.email         = ["sakuro@2238club.org"]
  gem.description   = %q{Remote TextMate}
  gem.summary       = %q{Edit files via TextMate running on a remote host.}
  gem.homepage      = "https://github.com/sakuro/rmate/"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rmate"
  gem.require_paths = ["lib"]
  gem.version       = Rmate::VERSION
end
