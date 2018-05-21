require "rails/railtie"
require 'active_record/connection_adapters/abstract_mysql_adapter'
require_relative '../mysql_adapter/schema_dumper'

module Scenic
  module Adapters
    class MySqlRailtie < Rails::Railtie
      ActiveSupport.on_load :active_record do
        unless ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.respond_to?(:views)
          # Versions of Rails < 5 need this patch to avoid listing views as tables in schema.rb
          ActiveRecord::SchemaDumper.prepend Scenic::Adapters::MySql::SchemaDumper
        end
      end
    end
  end
end
