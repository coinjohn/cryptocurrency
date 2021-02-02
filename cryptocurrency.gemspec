require_relative 'lib/cryptocurrency/version'

Gem::Specification.new do |spec|
  spec.name          = 'cryptocurrency'
  spec.version       = Cryptocurrency::VERSION
  spec.authors       = ['Crypto Jane']
  spec.email         = ['cryptojanedoe@protonmail.com']

  spec.summary       = 'Utility classes to securely work with cryptocurrencies.'
  spec.description   = 'Generate and verify addresses, sign transactions.'
  spec.homepage      = 'https://gitlab.com/cryptojane/cryptocurrency'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['allowed_push_host'] = "https://rubygems.org"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec'
end
