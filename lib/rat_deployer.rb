require 'rat_deployer/version'
require 'rat_deployer/config'

module RatDeployer
  def self.print_rat
    return unless RatDeployer::Config.prompt_enabled?
    puts File.read(File.join(__dir__, '../vendor/rat.txt'))
  end
end
