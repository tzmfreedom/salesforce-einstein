# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce/einstein/version'

Gem::Specification.new do |spec|
  spec.name          = 'salesforce-einstein'
  spec.version       = ::Salesforce::Einstein::VERSION
  spec.authors       = ['tzmfreedom']
  spec.email         = ['makoto_tajitsu@hotmail.co.jp']

  spec.summary       = %q{API client for Salesforce Einstein.}
  spec.description   = %q{API client for Salesforce Einstein(https://einstein.ai/).}
  spec.homepage      = 'https://github.com/tzmfreedom/salesforce-einstein'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'jwt', '~> 1.5'
  spec.add_runtime_dependency 'faraday'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.1'
  spec.add_development_dependency 'timecop', '~> 0.8'
end
