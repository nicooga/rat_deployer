# Rat

Rat is a deploy tool for docker users. It implements a facade around 3 docker CLIs:
  - docker
  - docker-compose
  - docker-machine
  
It is not very flexible and it is **untested**. I wrote this to avoid running a bunch of time consuming commands in a row.

![rat](http://mauveart.esy.es/img/rats/1_big.jpg)

I named it rat because it is a rather little and ugly ball of code, but it does the job for now.

## Features
Rat deployer adds a thin layer of abstraction over docker-compose to make commands more DRY.
Main features it adds are:

  - Enviromental overrides using multiple compose files
  - Easier remote usage by linking environments to machines
  - Slack notifier

## Installation

~~~bash
$ gem install rat_deployer
~~~

## Configuration
Rat searches for a file called `rat_config.yml` in the working dir. The options are:

- **project_name**: together with the environment, is part of the prefix passed to the `--project` option for `docker-compose`
- **environments**: holds environemntal config
  - **[*env*]**: parametric environment name
    - **machine**: configuration for remote usage. Links environment to a remote host. All paths can be relative to `rat_config.yml` file
      - **host**: IP for the remote machine
      - **ca_cert**: path to CA certificate
      - **cert**: path to SSL certificate used
      - **key**: path to SSL certificate key

Example config file:

~~~yaml
project_name: myapp

environments:
  staging:
    machine:
      host:    tcp://107.170.36.78:2376
      ca_cert: certs/ca.pem
      cert:    certs/cert.pem
      key:     certs/key.pem
~~~

## Env variable configuration
Rat most used options are set via environent variables to avoid having to type them all the time.

- **RAT_ENV**: current enviroment.
- **RAT_REMOTE**: whether or not to execute commands on remote host. Acceptable values are `true` and `false`. Defaults to `true`.

I recommend to export them if you are going to work on a environment for a long time:

~~~bash
$ export RAT_ENV=production RAT_REMOTE=false
~~~

## Usage

- `rat compose cmd`: proxies command to docker-compose adding flags `-f config/default.yml -f config/<env>.yml -p <prefix>`. If `RAT_REMOTE` is `true` adds flags for running on remote host.
- `rat deploy [services]`: just an alias for `rat compose pull [services] && rat compose up -d [services]`.
- `rat docker cmd`: proxies command to docker-compose adding flags for remote host ff `RAT_REMOTE` is `true`.

Example usage:

~~~base
$ export RAT_ENV=staging
$ rat compose up -d
||=> Running command `docker-compose -f config/default.yml -f config/staging.yml -p cognituz_staging up -d`
~~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rat_deployer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
