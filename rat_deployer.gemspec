# rubocop:disable Metrics/BlockLength
# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rat_deployer/version'

Gem::Specification.new do |spec|
  spec.name        = 'rat_deployer'
  spec.version     = RatDeployer::VERSION
  spec.authors     = ['Nicolas Oga']
  spec.email       = ['2112.oga@gmail.com']
  spec.summary     = 'A micro-framework to deploy dockerized apps'
  spec.description = 'A micro-framework to deploy dockerized apps'
  spec.homepage    = 'http://github.com/nicooga/rat_deployer'
  spec.license     = 'MIT'
  spec.files       =
    Dir[
      '{lib}/**/*.rb',
      'bin/*',
      'LICENSE',
      '*.md',
      'vendor/**/*'
    ]
  spec.executables   = ['rat']
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'thor', '~> 0.19.1'
  spec.add_runtime_dependency 'deep_merge', '~> 1.1.1'
  spec.add_runtime_dependency 'colorize', '~> 0.8.1'
  spec.add_runtime_dependency 'highline', '~> 1.7.8'
  spec.add_runtime_dependency 'slack-notifier', '~> 2.1.0'
  spec.add_runtime_dependency 'activesupport'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.6.0'
  spec.add_development_dependency 'activesupport', '~> 5.1.3'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'simplecov', '~> 0.15.0'
  spec.add_development_dependency 'rubocop', '~> 0.49.1'
end
