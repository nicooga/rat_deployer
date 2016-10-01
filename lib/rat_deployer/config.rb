require 'yaml'
require 'deep_merge'

module RatDeployer
  module Config
    def self.all
      @all ||= YAML.load_file File.expand_path('./rat_config.yml')
    end

    def self.env
      ENV.fetch('RAT_ENV')
    end

    def self.for_env(e = env)
      confs        = all.fetch('environments')
      default_conf = confs['default'] || confs['base'] || {}
      env_conf     = confs.fetch(e)

      default_conf.deep_merge env_conf
    end

    def self.for_service(service)
      for_env.fetch('images').fetch(service)
    end
  end
end
