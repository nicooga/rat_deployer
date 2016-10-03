# Rat

Rat is a deploy tool for docker users. It implements a facade around 3 docker CLIs:
  - docker
  - docker-compose
  - docker-machine
  
It is not very flexible and it is untested. I wrote this to avoid running a bunch of time consuming commands in a row.

![rat](http://mauveart.esy.es/img/rats/1_big.jpg)

I named it rat because it is a rather little and ugly ball of code, but it does the job for now.

## Why need yet another CLI??
My deploy process involves building and pushing a couple of images from my local computer, then connecting to the remote host, pulling the updated images and recreating the affected containers. This means running a bunch of commands that may take a lot of time to complete. I built rat to automate this process. 

## Installation

    $ gem install rat_deployer

## Usage
Rat searchs for a file called `rat_config.yml` in the working dir. This file describes some global variables and environment specific variables.

Example config file:

~~~yaml
project_name: myapp

images:
  'myapp/web:production':
    source: web # The name of the folder inside ./sources
    git:
      url: git@gitlab.com:myapp_developers/myapp.git

  'myapp/web:staging':
    source: web
    git:
      url: git@gitlab.com:myapp_developers/myapp.git
      branch: staging

  'myapp/nginx':
    source: nginx

environments:
  production:
    machine: myapp-production
  staging:
    machine: myapp-staging

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

Then to deploy:

~~~bash
$ RAT_ENV=staging rat deploy # to rebuild all images for which config is found in rat_config.yml
$ # or
$ RAT_ENV=staging rat deploy myapp/web:staging  # for an specific image
~~~

`rat deploy` will build and push the given images, connect to the remote machine, pull the new images, and recreate the affected containers. Other useful commands explained in the next section.

## Commands
  - `rat compose [CMD] [FLAGS...]`: simply runs given `docker-compose` command, but appends a couple of flags by convention: `-f config/default.yml -f config/$RAT_ENV.yml -p ${PROYECT_NAME}_$RAT_ENV`. This means you shoud put common docker-compose settings in config/default.yml and env specific config in config/<current_env>.yml.
  - `rat images update [IMAGES...]`: alias for `rat images build [IMAGES...] && rat images push [IMAGES...]`
  - `rat images build [IMAGES...]`: builds given images. If source for an image is not present in the path specified in the config, rat will try to clone if there is git sources configured.
  - `rat images push [IMAGES...]`: pushes given images
  - `rat deploy [IMAGES...]`: called with no arguments will `rat images update` all images and `rat compose pull && rat compose up -d` within the specified remote machine for the env. 

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rat_deployer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
