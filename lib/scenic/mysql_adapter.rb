require 'active_record'
require 'scenic'
require_relative 'adapters/my_sql'
require_relative 'mysql_adapter/version'
require_relative 'adapters/railtie' if defined?(Rails)
