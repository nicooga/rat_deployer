require 'open3'

module Helpers
  HISTORY_FILE =
    File.expand_path 'spec/support/dummy_binaries/.history', ROOT

  def run_cmd(cmd)
    Dir.chdir DUMMY_APP_PATH
    `#{cmd}`
  end

  def proxied_cmds
    `tail #{HISTORY_FILE}`.chomp.split("\n")
  end

  def proxied_cmd
    `tail -n 1 #{HISTORY_FILE}`.chomp
  end

  def reset_proxied_cmd_history
    `rm #{Helpers::HISTORY_FILE}`
    `touch #{Helpers::HISTORY_FILE}`
  end
end
