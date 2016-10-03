require 'thor'
require 'yaml'

require 'rat_deployer/config'
require 'rat_deployer/command'

module RatDeployer
  class Cli < Thor
    class Images < Thor
      include RatDeployer::Command

      desc 'update [SERVICES...]', 'Update images'
      def update(*images)
        get_images(images).each do |image|
          put_heading "Updating image #{image}"

          do_build(image)
          do_push(image)
        end
      end

      desc 'build [SERVICES...]', 'Build images'
      def build(*images)
        get_images(images).each &method(:do_build)
      end

      desc 'push [SERVICES...]', 'Push images'
      def push(*images)
        get_images(images).each &method(:do_push)
      end

      private

      def get_images(images)
        images.any? ? images : all_images
      end

      def all_images
        docker_conf = YAML.load(`RAT_PROMPT=false rat compose config`)
        images = docker_conf.fetch("services").map { |_, c| c.fetch("image") }.uniq
      end

      def do_build(image)
        put_heading "Building image #{image}"
        return unless image_conf_is_present?(image)
        ensure_image_source(image)
        run "docker build #{source_path(image)} -t #{image}"
      end

      def do_push(image)
        put_heading "Pusinhg image #{image}"
        return unless image_conf_is_present?(image)
        run "docker push #{image}"
      end

      def ensure_image_source(image)
        if git_conf(image)
          git_clone_repo(image) unless source_present?(image)
          git_fetch(image)
          git_checkout(image)
        else
          unless source_present?(image)
            put_error "Source for image #{image} is not present and no git config was provided for it. Either provide git url and optionally branch or provision the source yourself at #{source_path(image)}"
          end
        end
      end

      def git_clone_repo(image)
        url = image_conf(image).fetch('git').fetch('url')
        run "git clone #{url} #{source_path(image)}"
      end

      def git_checkout(image)
        run "git -C #{source_path(image)} checkout -f #{git_branch(image)}"
        run "git -C #{source_path(image)} reset --hard origin/#{git_branch(image)}"
      end

      def git_fetch(image)
        run "git -C #{source_path(image)} fetch origin #{git_branch(image)}"
      end

      def git_branch(image)
        git_conf(image).fetch('branch', 'master')
      end

      def git_conf(image)
        image_conf(image)['git']
      end

      def image_conf(image)
        RatDeployer::Config.images[image]
      end

      def source_path(image)
        folder = image_conf(image).fetch('source', image)
        File.expand_path("./sources/#{folder}")
      end

      def source_present?(image)
        File.exists? source_path(image)
      end

      def image_conf_is_present?(image)
        if image_conf(image)
          true
        else
          put_warning "No image config found for image #{image}. Skipping"
          false
        end
      end
    end
  end
end
