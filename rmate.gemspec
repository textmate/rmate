# -*- encoding: utf-8 -*-
require File.expand_path('lib/rmate', File.dirname(__FILE__))

Gem::Specification.new do |gem|
  gem.name          = 'rmate'
  gem.version       = Rmate::VERSION
  gem.date          = Rmate::DATE
  gem.description   = %q{Remote TextMate}
  gem.summary       = %q{Edit files from anywhere in TextMate 2 on your local Mac.}
  gem.email         = ['rmate@textmate.org']
  gem.homepage      = 'https://github.com/textmate/rmate/'
  gem.license       = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.authors       = `git log --pretty='format:%an' -- . ':!README*'|sort|uniq -c|sort -k2|sort -srnk1|sed -E 's/^ *[0-9]+ //'`.split("\n")
end
