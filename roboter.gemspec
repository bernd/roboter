# -*- encoding: utf-8 -*-
require File.expand_path('../lib/roboter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Bernd Ahlers"]
  gem.email         = ["bernd@tuneafish.de"]
  gem.description   = %q{A robot framework}
  gem.summary       = %q{A robot framework}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "roboter"
  gem.require_paths = ["lib"]
  gem.version       = Roboter::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard-rspec"

  gem.add_runtime_dependency "blather"
end
