require 'colorize'
require 'highline/import'
require 'rat_deployer/config'
require 'English'

module RatDeployer
  # Rat::Deployer encapsulates all code related to running a shell command
  # and displaying it's output.
  module Command
    def run(cmd, silent: false)
      if !silent && RatDeployer::Config.prompt_enabled?
        puts '||=> Running command '.colorize(:blue) +
             "`#{cmd.colorize(:white)}`"
      end

      command = do_run(cmd, silent: silent)
      exit 1 unless command.fetch(:status).zero?
      command
    end

    def do_run(cmd, silent: false)
      output = ''
      status = 1

      IO.popen(ENV, cmd) do |io|
        while line = io.gets # rubocop:disable Lint/AssignmentInCondition
          puts line unless silent
          output << line
        end
        io.close
        status = $CHILD_STATUS.to_i
      end

      { output: output, status: status }
    end

    def put_heading(str)
      return unless RatDeployer::Config.prompt_enabled?
      puts "|| #{str}".colorize(:blue)
    end

    def put_error(str)
      return unless RatDeployer::Config.prompt_enabled?
      puts "// #{str}".colorize(:red)
    end

    def put_warning(str)
      return unless RatDeployer::Config.prompt_enabled?
      puts colorize_warning(str)
    end

    def colorize_warning(str)
      "\\\\ #{str}".colorize(:yellow)
    end
  end
end
