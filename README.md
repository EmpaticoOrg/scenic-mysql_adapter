# ScenicMysqlAdapter

MySQL adapter for [scenic](https://github.com/thoughtbot/scenic).

[![Gem](https://img.shields.io/gem/v/scenic-mysql_adapter.svg)](https://rubygems.org/gems/scenic-mysql_adapter)[![master branch](https://img.shields.io/circleci/project/github/EmpaticoOrg/scenic-mysql_adapter.svg)](https://circleci.com/gh/EmpaticoOrg/scenic-mysql_adapter/tree/master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scenic-mysql_adapter'
```

And then execute:

    $ bundle

Then create the following file:

```ruby
# config/initializers/scenic.rb

Scenic.configure do |config|
  config.database = Scenic::Adapters::MySQL.new
end
```

## Limitations

MySQL does not support materialized views.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/EmpaticoOrg/scenic-mysql_adapter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the ScenicMysqlAdapter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/EmpaticoOrg/scenic-mysql_adapter/blob/master/CODE_OF_CONDUCT.md).
