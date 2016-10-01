require "colorize"
require 'highline/import'

module RatDeployer
  module Command
    def run(cmd)
      msg = "||=> Running command ".colorize(:blue) + "`#{cmd.colorize(:white)}`"
      puts msg
      system cmd
    end

    def put_heading(str)
      puts "|| #{str}".colorize(:blue)
    end

    def put_error(str)
      puts "// #{str}".colorize(:red)
    end

    def put_warning(str)
      puts colorize_warning(str)
    end

    def ask_for_confirmation
      prompt = "Are you sure you want to continue?"

      a = ''
      s = '[y/n]'
      d = 'y'

      until %w[y n].include? a
        a = ask(colorize_warning("#{prompt} #{s} ")) { |q| q.limit = 1; q.case = :downcase }
        a = d if a.length == 0
      end

      exit 1 unless a == 'y'
    end

    def colorize_warning(str)
      "\\\\ #{str}".colorize(:yellow)
    end
  end
end
