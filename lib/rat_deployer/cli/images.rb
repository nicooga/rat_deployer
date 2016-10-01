require 'thor'

require 'rat_deployer/config'
require 'rat_deployer/command'

module RatDeployer
  class Cli < Thor
    class Images < Thor
      include RatDeployer::Command

      desc 'update [SERVICES...]', 'Update images for given services'
      def update(*services)
        build(*services)
        push(*services)
      end

      desc 'build [SERVICES...]', 'Build images for given services'
      def build(*services)
        services.each &method(:do_build)
      end

      desc 'push [SERVICES...]', 'Push images for given services'
      def push(*services)
        services.each &method(:do_push)
      end

      private

      def do_build(service)
        put_heading "Building service #{service}"

        ensure_image_source(service)

        run "docker build #{source_path(service)} -t #{image_name(service)}"
      end

      def do_push(service)
        run "docker push #{image_name(service)}"
      end

      def ensure_image_source(service)
        if git_conf(service)
          git_clone_repo(service) unless File.exists? source_path(service)
          git_checkout(service)
          git_pull(service)
        else
          unless File.exists? source_path(service)
            put_error <<-ERROR
              No source found for service #{service}."
              Either specify git[url] or provision the source for #{service} yourself.
            ERROR
          end
        end
      end

      def git_clone_repo(service)
        url = git_conf(service).fetch("url")
        run "git clone #{url} sources/#{service}"
      end

      def git_checkout(service)
        branch = git_conf(service).fetch("branch", "master")
        run "git -C #{source_path(service)} checkout -f #{branch}"
      end

      def git_pull(service)
        branch = git_conf(service).fetch("branch", "master")
        run "git -C #{source_path(service)} pull origin #{branch}"
      end

      def source_path(service)
        File.expand_path("./sources/#{service}")
      end

      def git_conf(service)
        RatDeployer::Config.for_service(service)["git"]
      end

      def image_name(service)
        RatDeployer::Config.for_service(service).fetch("name")
      end
    end
  end
end
