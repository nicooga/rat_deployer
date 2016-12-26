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

    def self.images
      all.fetch('images', {})
    end

    def self.environmental
      all.fetch('environments', {})
    end

    def self.for_env(e = env)
      default_conf = environmental.fetch('default', {})
      env_conf     = environmental.fetch(e)
      default_conf.deep_merge(env_conf)
    end

    def self.machine
      for_env.fetch("machine")
    end

    def self.remote
      env_var = ENV['RAT_REMOTE']
      env_var.nil? ? true : env_var == 'true'
    end

    def self.prompt_enabled?
      ENV['RAT_PROMPT'] != "false"
    end
  end
end
