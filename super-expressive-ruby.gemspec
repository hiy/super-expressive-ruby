require_relative 'lib/super-expressive-ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "super-expressive-ruby"
  spec.version       = SuperExpressive::Ruby::VERSION
  spec.authors       = ["Hiroshi Yamasaki"]
  spec.email         = ["ymskhrs@gmail.com"]

  spec.summary       = "Build regular expressions in almost natural language"
  spec.description   = "This gem is a port of https://github.com/francisrstokes/super-expressive"
  spec.homepage      = "https://github.com/hiy/super-expressive-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hiy/super-expressive-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/hiy/super-expressive-ruby"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "activesupport", '6.0'
end
