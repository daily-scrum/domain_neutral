$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "domain_neutral/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "domain_neutral"
  s.version     = DomainNeutral::VERSION
  s.authors     = ["Knut I. Stenmark"]
  s.email       = ["knut.stenmark@gmail.com"]
  s.homepage    = "https://github.com/daily_scrum/domain_neutral"
  s.summary     = "DomainNeutral provides domain neutral model classes needed for most projects"
  s.description = <<-END
    Model framework for for domain neutral classes, such as Descriptor which is fundamental for every database
    to describe characteristics of an object.
  END
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"

  s.add_development_dependency "sqlite3"
end
