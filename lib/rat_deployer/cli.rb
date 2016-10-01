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
      images = RatDeployer::Config.for_env["images"]

      if images.any?
        unset_machine
        run "rat images update #{images.keys.join(' ')}"
        set_machine
        run "rat compose pull"
      end

      set_machine
      run "rat compose up -d"
      unset_machine
    end

    desc "compose ARGS...", "runs docker-compose command with default flags"
    def compose(cmd, *cmd_flags)
      warn_if_running_on_remote_host

      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = [
        "-f config/default.yml",
        "-f config/#{env}.yml",
        "-p #{project_name}_#{env}"
      ].join(' ')

      run "docker-compose #{flags} #{cmd} #{cmd_flags.join(" ")}"
    end

    desc "set_machine", "sets machine as configured in your rat_file"
    def set_machine
      machine = RatDeployer::Config.for_env.fetch("machine")
      run "eval $(docker-machine env #{machine})"
    end

    desc "unset_machine", "unsets machine"
    def unset_machine
      run "eval $(docker-machine env --unset)"
    end

    private
    
    def warn_if_running_on_remote_host
      machine = ENV["DOCKER_MACHINE"]

      if machine
        put_warning "Your docker client is pointing to the remote machine #{machine}"
        ask_for_confirmation
      end
    end
  end
end
