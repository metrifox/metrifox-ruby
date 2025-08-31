require_relative 'lib/metrifox_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = "metrifox-sdk"
  spec.version       = MetrifoxSdk::VERSION
  spec.authors       = ["TheCodeNinja"]
  spec.email         = ["ibrahim@metrifox.com"]

  spec.summary       = "Ruby SDK for Metrifox API"
  spec.description   = "A Ruby SDK for interacting with the Metrifox platform API"
  spec.homepage      = "https://github.com/metrifox/metrifox-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/metrifox/metrifox-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/metrifox/metrifox-ruby/tree/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["lib/**/*", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "net-http", "~> 0.3"
  spec.add_dependency "uri", "~> 0.12"
  spec.add_dependency "json", "~> 2.0"
  spec.add_dependency "mime-types", "~> 3.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "dotenv", "~> 2.8"
end