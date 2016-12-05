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
      run "rat images update"
      run "rat compose pull"
      run "rat compose up -d"
    end

    desc "compose ARGS...", "runs docker-compose command with default flags"
    def compose(cmd, *cmd_flags)
      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = [
        "-f config/default.yml",
        "-f config/#{env}.yml",
        "-p #{project_name}_#{env}"
      ]

      flags.unshift(remote_machine_flags) if RatDeployer::Config.remote

      run "docker-compose #{flags.join(' ')} #{cmd} #{cmd_flags.join(" ")}"
    end

    desc "docker ARGS...", "runs docker command with default flags"
    def docker(cmd, *cmd_flags)
      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = []
      flags.unshift(remote_machine_flags) if RatDeployer::Config.remote

      run "docker #{flags.join(' ')} #{cmd} #{cmd_flags.join(" ")}"
    end

    private

    def remote_machine_flags
      `docker-machine config #{RatDeployer::Config.machine}`.gsub(/\n/, ' ')
    end

    #def warn_if_running_on_remote_host
      #if machine = ENV["DOCKER_MACHINE"]
        #put_warning "Your docker client is pointing to the remote machine #{machine}"
        #ask_for_confirmation
      #end
    #end
  end
end
