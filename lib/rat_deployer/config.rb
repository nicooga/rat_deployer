require 'yaml'
require 'deep_merge'

module RatDeployer
  # This module handles config fetching from env and config files
  module Config
    def self.all
      @all ||= YAML.load_file(File.expand_path('./rat_config.yml')) || {}
    end

    def self.for_env(e = env)
      environmental = all.fetch('environments', {})
      default_conf = environmental.fetch('default', {})
      env_conf     = environmental.fetch(e, {})

      default_conf.deep_merge(env_conf)
    end

    def self.prompt_enabled?
      ENV['RAT_PROMPT'] != 'false'
    end

    def self.remote
      ENV['RAT_REMOTE'] =~ /true|1|yes/
    end

    def self.env
      ENV['RAT_ENV'] || 'default'
    end

    def self.images
      all.fetch('images', {})
    end

    def self.project_name
      (for_env['project_name'] || all.fetch('project_name'))
        .gsub(/\{env\}/, env)
    end

    def self.remote_machine_flags
      machine = for_env.fetch('machine')

      case machine
      when Hash
        [
          '--tlsverify',
          "-H='#{machine.fetch('host')}'",
          "--tlscacert='#{machine.fetch('ca_cert')}'",
          "--tlscert='#{machine.fetch('cert')}'",
          "--tlskey='#{machine.fetch('key')}'"
        ].join(' ')
      else
        raise 'Bad configuration value for `machine`'
      end
    end
  end
end
