# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'calabash/version'

ruby_files = Dir.glob('{lib,bin}/**/*.rb')
doc_files =  ['README.md', 'LICENSE', 'CONTRIBUTING.md', 'VERSIONING.md']
gem_files = ruby_files + doc_files

Gem::Specification.new do |spec|
  spec.name          = 'calabash'
  spec.authors       = ['Jonas Maturana Larsen',
                        'Karl Krukow',
                        'Tobias Røikjer',
                        'Joshua Moody']
  spec.email         = ['jonaspec.larsen@xamarin.com',
                        'karl.krukow@xamarin.com',
                        'tobias.roikjer@xamarin.com',
                        'joshua.moody@xamarin.com']

  spec.summary       = 'Automated Acceptance Testing for Mobile Apps'
  spec.description   =
        %q{Calabash is a Behavior-driven development (BDD)
framework for Android and iOS. It supports both native and hybrid app testing.

It is developed and maintained by Xamarin and is released under the Eclipse
Public License.}

  spec.homepage      = 'https://xamarin.com/test-cloud'
  spec.license       = 'EPL-1.0'

  spec.required_ruby_version = '>= 1.9'
  spec.version       = Calabash::VERSION
  spec.platform      = Gem::Platform::RUBY

  spec.files         = gem_files
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'cucumber', '~> 1.3'
  spec.add_dependency 'calabash-common', '~> 0.0', '>= 0.0.1'
  spec.add_dependency 'edn', '~> 1.0', '>= 1.0.6'
  spec.add_dependency 'slowhandcuke','~> 0.0', '>= 0.0.3'
  spec.add_dependency 'geocoder', '~> 1.1', '>= 1.1.8'
  spec.add_dependency 'httpclient', '~> 2.3'
  spec.add_dependency 'awesome_print', '~> 1.2'
  spec.add_dependency 'escape', '~> 0.0', '>= 0.0.4'
  spec.add_dependency 'CFPropertyList','~> 2.2'
  spec.add_dependency 'sim_launcher', '< 0.5', '>= 0.4.13'
  spec.add_dependency 'run_loop', '~> 1.1'

  # These dependencies should match the xamarin-test-cloud dependencies.
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'bundler', '>= 1.3.0', '< 2.0'
  spec.add_dependency 'retriable', '~> 1.3', '>= 1.3.3.1'
  spec.add_dependency 'rubyzip', '~> 1.1'
  spec.add_dependency 'thor', '~> 0.18', '>= 0.18.1'

  # Development dependencies.
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'redcarpet', '~> 3.1'
  spec.add_development_dependency 'travis', '~> 1.7'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'guard-bundler', '~> 2.0'
  spec.add_development_dependency 'growl', '~> 1.0'

end
