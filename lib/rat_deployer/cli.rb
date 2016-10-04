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
      unset_machine
      run "rat images update"

      within_machine do
        run "rat compose pull"
        run "rat compose up -d"
      end
    end

    desc "compose ARGS...", "runs docker-compose command with default flags"
    def compose(cmd, *cmd_flags)
      env          = RatDeployer::Config.env
      project_name = RatDeployer::Config.all.fetch('project_name')

      flags = [
        "-f config/default.yml",
        "-f config/#{env}.yml",
        "-p #{project_name}_#{env}"
      ].join(' ')

      within_machine do
        run "docker-compose #{flags} #{cmd} #{cmd_flags.join(" ")}"
      end
    end

    private

    def set_machine
      machine = RatDeployer::Config.for_env.fetch("machine")
      run "eval $(docker-machine env #{machine})"
    end

    def unset_machine
      run "eval $(docker-machine env --unset)"
    end

    def within_machine(&block)
      set_machine
      yield
    ensure
      unset_machine
    end

    #def warn_if_running_on_remote_host
      #if machine = ENV["DOCKER_MACHINE"]
        #put_warning "Your docker client is pointing to the remote machine #{machine}"
        #ask_for_confirmation
      #end
    #end
  end
end
