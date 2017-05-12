require 'thor'

require 'rat_deployer/command'
require 'rat_deployer/notifier'

module RatDeployer
  class Cli < Thor
    include RatDeployer::Command

    desc "deploy", "deploys current environment"
    def deploy(*services)
      RatDeployer::Notifier.notify_deploy_start

      if services.any?
        services_str = services.join(' ')
        RatDeployer::Cli.new.compose("pull #{services_str}")
        RatDeployer::Cli.new.compose("up -d --no-deps --force-recreate #{services_str}")
      else
        RatDeployer::Cli.new.compose('pull')
        RatDeployer::Cli.new.compose('up -d')
      end

      RatDeployer::Notifier.notify_deploy_end
    rescue Exception => e
      RatDeployer::Notifier.notify <<-STR
Failed deploy on #{ENV.fetch('RAT_ENV')}"
Reason:
  #{e.message}
      STR
      raise e
    end

    desc "compose ARGS...", "runs docker-compose command with default flags"
    def compose(cmd, *cmd_flags, silent: false)
      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = [
        "-f config/default.yml",
        "-f config/#{env}.yml",
        "-p #{project_name}_#{env}"
      ]

      if RatDeployer::Config.remote
        flags.unshift(RatDeployer::Config.remote_machine_flags)
      end

      cmd = run "docker-compose #{flags.join(' ')} #{cmd} #{cmd_flags.join(" ")}", silent: silent
      cmd.fetch(:output)
    end

    desc "docker ARGS...", "runs docker command with default flags"
    def docker(cmd, *cmd_flags)
      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = []

      if RatDeployer::Config.remote
        flags.unshift(RatDeployer::Config.remote_machine_flags)
      end

      cmd = run "docker #{flags.join(' ')} #{cmd} #{cmd_flags.join(" ")}"
      cmd.fetch(:output)
    end
  end
end
