# coding: utf-8

require File.join(File.dirname(__FILE__), 'lib', 'calabash', 'version')

lib_files = Dir.glob('{lib,bin}/**/{.irbrc,*.{rb,feature,yml}}')
doc_files =  ['README.md', 'LICENSE', 'CONTRIBUTING.md', 'VERSIONING.md']
jar_files =  ['lib/calabash/android/lib/screenshot_taker.jar']
calmd5_exe = Dir.glob('lib/calabash/android/lib/calmd5/**/{calmd5,calmd5-pie}')
test_server_apk = Dir.glob('lib/calabash/android/lib/TestServer.apk')
android_manifest = Dir.glob('lib/calabash/android/lib/AndroidManifest.xml')
helper_application = Dir.glob('lib/calabash/android/lib/HelperApplication.apk')
helper_application_test_server = Dir.glob('lib/calabash/android/lib/HelperApplicationTestServer.apk')
playback_files = Dir.glob('lib/calabash/ios/lib/recordings/**/*.base64')
skeleton_dir = 'lib/calabash/lib/skeleton'
skeleton_files = Dir.glob(File.join(skeleton_dir,'**/*')) << (File.join(skeleton_dir,'.gitignore'))

gem_files = lib_files + doc_files + jar_files + calmd5_exe + playback_files + test_server_apk + android_manifest +
    skeleton_files + helper_application + helper_application_test_server

Gem::Specification.new do |spec|
  spec.name          = 'calabash'
  spec.authors       = ['Karl Krukow',
                        'Tobias Røikjer',
                        'Joshua Moody']
  spec.email         = ['karl.krukow@xamarin.com',
                        'tobias.roikjer@xamarin.com',
                        'joshua.moody@xamarin.com']

  spec.summary       = 'Automated Acceptance Testing for Mobile Apps'
  spec.description   =
        %q{Calabash is a mobile automation tool used for automatic UI-testing.
It supports Android and iOS, both native and hybrid app testing.

It is developed and maintained by Xamarin and is released under the Eclipse
Public License.}

  spec.homepage      = 'https://xamarin.com/test-cloud'
  spec.license       = 'EPL-1.0'

  spec.required_ruby_version = '>= 2.0'

  spec.version       = Calabash::VERSION
  spec.platform      = Gem::Platform::RUBY

  spec.files         = gem_files
  spec.executables   = 'calabash'
  spec.require_paths = ['lib']

  spec.add_dependency 'edn', '>= 1.0.6', '< 2.0'
  spec.add_dependency 'geocoder', '>= 1.1.8', '< 2.0'
  spec.add_dependency 'httpclient', '~> 2.6'
  spec.add_dependency 'escape', '>= 0.0.4', '< 1.0'
  spec.add_dependency 'run_loop', ">= 2.0.2", "< 3.0"
  spec.add_dependency 'clipboard'

  # These dependencies should match the xamarin-test-cloud dependencies.
  spec.add_dependency 'rubyzip', '~> 1.1'
  spec.add_dependency 'bundler', '>= 1.3.0', '< 2.0'

  # Run-loop should control the version.
  spec.add_dependency 'awesome_print'
  spec.add_dependency 'json'
  spec.add_dependency 'luffa'

  # Development dependencies.
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'redcarpet', '~> 3.1'

  # Run-loop should control the version.
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'travis'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'
  # Pin to 3.0.6; >= 3.1.0 requires ruby 2.2. This is guard dependency.
  spec.add_development_dependency("listen", "3.0.6")
  spec.add_development_dependency 'growl'

  spec.add_development_dependency 'stub_env'
end
