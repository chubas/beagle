# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'beagle/version'

Gem::Specification.new do |s|
  s.name = "beagle"
  s.version = Beagle::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Rubén Medellín"],
  s.email = %w(chubas@freshout.us),
  s.homepage = ""
  s.summary = %q(Beagle is a library to provide approximations to an open-ended result given generational variances, given a set of constraints)
  s.description = %q(Generational approximation library)

  s.rubyforge_project = 'beagle'

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_dependency 'rgl'
  s.add_development_dependency 'yard'
end
