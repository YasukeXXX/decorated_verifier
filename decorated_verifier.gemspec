$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "decorated_verifier/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "decorated_verifier"
  s.version     = DecoratedVerifier::VERSION
  s.authors     = ["yasukexxx"]
  s.email       = ["yasukexxx@gmail.com"]
  s.homepage    = "https://github.com/yasukexxx/decorated_verifier"
  s.summary     = ""
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_runtime_dependency "activesupport", ">= 4.1"
  s.add_runtime_dependency "activemodel", ">= 4.1"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry-rails"
end
