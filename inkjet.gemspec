$:.push File.expand_path("../lib", __FILE__)
require "inkjet/version"

Gem::Specification.new do |s|
  s.name        = "inkjet"
  s.version     = Inkjet::VERSION
  s.summary     = "Pretty output for ruby cli scripts"
  s.description = "Formatting, indentation, bash colors, etc. for ruby cli script output"
  s.authors     = ["Mark Rebec"]
  s.email       = ["mark@markrebec.com"]
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["spec/**/*"]
  s.homepage    = "http://github.com/markrebec/inkjet"

  s.add_dependency "activesupport"
  s.add_development_dependency "rspec"
end
