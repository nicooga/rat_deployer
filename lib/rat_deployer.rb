require 'rat_deployer/version'
require 'rat_deployer/config'

# Rat is a deploy tool for docker users.
# It implements a facade around 2 docker CLIs:
#   - docker
#   - docler-compose
#
# It is not very flexible and it is lightly tested.
# I named it rat because it is a rather little and
# ugly ball of code, but it does the job for now.
module RatDeployer
  def self.print_rat
    return unless RatDeployer::Config.prompt_enabled?
    puts File.read(File.join(__dir__, '../vendor/rat.txt'))
  end
end
