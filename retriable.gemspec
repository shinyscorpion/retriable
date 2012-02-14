# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)
require "retriable/version"

Gem::Specification.new do |s|
  s.name        = "retriable"
  s.version     = Retriable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jack Chu"]
  s.email       = ["jack@jackchu.com"]
  s.homepage    = %q{http://github.com/kamui/retriable}
  s.summary     = %q{Retriable is an simple DSL to retry code if an exception is raised.}
  s.description = %q{Retriable is an simple DSL to retry code if an exception is raised. This is especially useful when interacting external api/services or file system calls.}

  s.rubyforge_project = "retriable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
end
