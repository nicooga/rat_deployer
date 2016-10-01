# Rat

Rat is a deploy tool for docker users. It implements a facade around 3 docker CLIs:
  - docker
  - docker-compose
  - docker-machine
  
It is not very flexible and it is untested. I wrote this to avoid running a bunch of time consuming commands in a row.

![rat](http://mauveart.esy.es/img/rats/1_big.jpg)

I named it rat because it is a rather little and ugly ball of code, but it does the job for now.

## Installation

    $ gem install rat_deployer

## Usage
Rat searchs for a file called `rat_config.yml` in the working dir. This file describes some global variables and environment specific variables.

Example config file:

~~~yaml
project_name: my_app # Required

environments:
  default: # base config, env specific configuration gets deep merged
    images:
      web:
        git:
          url: git@gitlab.com:my_app_developers/my_app.git
      nginx:
        name: my_app/nginx # Required

  production:
    machine: my_app-production # Required
    images:
      web:
        name: my_app/web:production # Required

  staging:
    machine: my_app-staging # Required
    images:
      web:
        name: my_app/web:staging # Required
        git:
          branch: staging
~~~

This is what my dir structure looks like:

~~~bash
├── config # required
│   ├── base.yml
│   ├── development.yml
│   ├── production.yml
│   └── staging.yml
├── env # optional
│   ├── development.env
│   ├── production.env
│   └── staging.env
├── sources # Here go image sources. You can either manage this by hand or use rat to specify git sources
│   ├── nginx
│   └── web
└── rat_config.yml
~~~

The rest is pretty much self-explanatory:

~~~bash
$ RAT_ENV=production rat deploy
||=> Running command `eval $(docker-machine env --unset)`
||=> Running command `rat images update web nginx`
|| Building service web
||=> Running command `git -C /home/nepto/Source/my_app_deploy/sources/web checkout -f staging`
Already on 'staging'
Your branch is up-to-date with 'origin/staging'.
||=> Running command `git -C /home/nepto/Source/my_app_deploy/sources/web pull origin staging`
From gitlab.com:my_app_developers/my_app
 * branch            staging    -> FETCH_HEAD
Already up-to-date.
||=> Running command `docker build /home/nepto/Source/my_app_deploy/sources/web -t my_app/web:staging`
# ... output
|| Building service nginx
||=> Running command `docker build /home/nepto/Source/my_app_deploy/sources/nginx -t my_app/nginx`
# ... output
||=> Running command `docker push my_app/web:staging`
# ... output
||=> Running command `docker push my_app/nginx`
# ... output
||=> Running command `docker-compose -f config/base.yml -f config/staging.yml -p my_app_staging pull`
# ... output
||=> Running command `docker-compose -f config/base.yml -f config/staging.yml -p my_app_staging up -d`
# ... output
~~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rat_deployer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
