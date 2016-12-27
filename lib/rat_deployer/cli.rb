require 'thor'

require 'rat_deployer/cli/images'
require 'rat_deployer/command'

module RatDeployer
  class Cli < Thor
    include RatDeployer::Command

    desc 'images SUBCOMMAND ...ARGS', 'manage images'
    subcommand 'images', RatDeployer::Cli::Images

    desc "deploy", "deploys current environment"
    def deploy
      RatDeployer::Cli::Images.new.update
      RatDeployer::Cli.new.compose('pull')
      RatDeployer::Cli.new.compose('up -d')
    end

    desc "compose ARGS...", "runs docker-compose command with default flags"
    def compose(cmd, *cmd_flags)
      etnv          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = [
        "-f config/default.yml",
        "-f config/#{env}.yml",
        "-p #{project_name}_#{env}"
      ]

      if RatDeployer::Config.remote
        flags.unshift(RatDeployer::Config.remote_machine_flags)
      end

      run "docker-compose #{flags.join(' ')} #{cmd} #{cmd_flags.join(" ")}"
    end

    desc "docker ARGS...", "runs docker command with default flags"
    def docker(cmd, *cmd_flags)
      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = []

      if RatDeployer::Config.remote
        flags.unshift(RatDeployer::Config.remote_machine_flags)
      end

      run "docker #{flags.join(' ')} #{cmd} #{cmd_flags.join(" ")}"
    end
  end
end
