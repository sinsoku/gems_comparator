# GemsComparator

[![Gem Version](https://badge.fury.io/rb/gems_comparator.svg)](https://badge.fury.io/rb/gems_comparator)
[![Build Status](https://travis-ci.org/sinsoku/gems_comparator.svg?branch=master)](https://travis-ci.org/sinsoku/gems_comparator)
![Coverage](https://img.shields.io/badge/Coverage-100%25-green.svg)

GemsComparator generates GitHub's compare view urls from the difference between two `Gemfile.lock`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gems_comparator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gems_comparator

## Usage

```rb
require 'gems_comparator'

before_lockfile = File.read('before_Gemfile.lock')
after_lockfile = File.read('after_Gemfile.lock')

GemsComparator.compare(before_lockfile, after_lockfile)
```

Here's an example that the `compare` method return:

```rb
[{
  :name=>"rake",
  :before=>"11.3.0",
  :after=>"12.0.0",
  :homepage=>"https://github.com/ruby/rake",
  :github_url=>"https://github.com/ruby/rake",
  :compare_url=>"https://github.com/ruby/rake/compare/v11.3.0...v12.0.0"
}, {
  ...
}]
```

## Configuring

To use an access token, set your token to `ENV['GITHUB_TOKEN']`. Or you can also set a token through the `configure` method.

```rb
GemsComparator.configure do |config|
  config.client = Octokit::Client.new(access_token: '<your 40 char token>')
end
```

## Parallel Support

If you are using a [parallel](https://github.com/grosser/parallel) gem, GemsComparator automatically works as parallel processing.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sinsoku/gems_comparator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

