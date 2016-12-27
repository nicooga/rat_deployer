# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rat_deployer/version'

Gem::Specification.new do |spec|
  spec.name          = "rat_deployer"
  spec.version       = RatDeployer::VERSION
  spec.authors       = ["Nicolas Oga"]
  spec.email         = ["2112.oga@gmail.com"]
  spec.summary       = %q{A micro-framework to deploy dockerized apps}
  spec.description   = %q{A micro-framework to deploy dockerized apps}
  spec.homepage      = "http://github.com/nicooga/rat_deployer"
  spec.license       = "MIT"
  spec.files         = %w(
    lib/rat_deployer.rb
    lib/rat_deployer/cli.rb
    lib/rat_deployer/cli/images.rb
    lib/rat_deployer/command.rb
    lib/rat_deployer/config.rb
    lib/rat_deployer/version.rb
    lib/rat_deployer/notifier.rb
    vendor/rat.txt
  )
  spec.executables   = ["rat"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 0.19.1"
  spec.add_runtime_dependency "deep_merge", "~> 1.1.1"
  spec.add_runtime_dependency "colorize", "~> 0.8.1"
  spec.add_runtime_dependency "highline", "~> 1.7.8"
  spec.add_runtime_dependency "slack-notifier"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
