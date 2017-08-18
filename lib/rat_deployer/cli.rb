require 'thor'
require 'fileutils'

require 'rat_deployer/commands/compose'
require 'rat_deployer/commands/deploy'
require 'rat_deployer/commands/docker'

module RatDeployer
  # The main Thor subclass
  class Cli < Thor
    include Commands::Compose::Extension
    include Commands::Deploy::Extension
    include Commands::Docker::Extension
  end
end
