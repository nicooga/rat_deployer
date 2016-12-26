require 'rat_deployer/version'
require 'rat_deployer/config'

module RatDeployer
  def self.print_rat
    return unless RatDeployer::Config.prompt_enabled?

    rat = <<-RAT

                   DEPLOY RAT
    (\,/)          WORKING
    oo   '''//,        _
  ,/_;~,        \,    / '
  "'   \    (    \    !
        ',|  \    |__.'
        '~  '~----''

    RAT

    puts rat
  end
end
