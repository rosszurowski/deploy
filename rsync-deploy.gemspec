lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'deploy/version'

Gem::Specification.new do |s|
  
  s.name          = 'rsync-deploy'
  s.version       = Deploy::VERSION
  s.date          = '2013-12-23'

  s.summary       = "Deployments based on rsync"
  s.description   = "A simple rsync based deployment gem"

  s.authors       = ["Ross Zurowski"]
  s.email         = 'ross@rosszurowski.com'
  s.homepage      = 'https://github.com/rosszurowski/deploy'
  s.license       = 'WTFPL'

  s.require_paths = ["lib"]
  
  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  
  s.files         = `git ls-files`.split($/)
  s.files         += Dir.glob("lib/**/*.rb")
  s.executables   = ["deploy"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  
end