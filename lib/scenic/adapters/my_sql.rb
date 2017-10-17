require_relative '../mysql_adapter/views'

module Scenic
  module Adapters
    class MySQL
      class FeatureNotSupportedError < StandardError
        def initialize
          super 'MySQL does not support this feature'
        end
      end

      def initialize(connectable = ActiveRecord::Base)
        @connectable = connectable
      end

      def views
        Scenic::MySQLAdapter::Views.new(
          view_names.map do |name|
            Scenic::View.new(
              name: name,
              definition: view_definition(name),
              materialized: false
            )
          end,
          dependencies
        ).tsort
      end

      def create_view(name, sql_definition)
        execute "CREATE VIEW #{quote_table_name(name)} AS #{sql_definition}"
      end

      def replace_view(name, sql_definition)
        execute "CREATE OR REPLACE VIEW #{quote_table_name(name)} AS #{sql_definition}"
      end

      def drop_view(name)
        execute "DROP VIEW #{quote_table_name(name)}"
      end

      def update_view(name, sql_definition)
        drop_view(name)
        create_view(name, sql_definition)
      end

      def create_materialized_view(*_)
        raise FeatureNotSupportedError
      end

      def update_materialized_view(*_)
        raise FeatureNotSupportedError
      end

      def drop_materialized_view(*_)
        raise FeatureNotSupportedError
      end

      delegate :connection, to: :@connectable
      delegate :execute, :quote_table_name, to: :connection

      private def dependencies
        result = execute(<<-SQL)
          SELECT
            views.table_name As `View`,
            other_views.table_name AS `Dependency`
          FROM information_schema.views AS views
          INNER JOIN information_schema.views AS other_views
             ON views.table_schema = other_views.table_schema
            AND views.view_definition LIKE CONCAT('%`', other_views.table_name,'`%')
          WHERE views.table_schema = '#{@connectable.connection.current_database}';
        SQL

        graph = Hash.new { |h, k| h[k] = [] }
        result.each_with_object(graph) do |row, memo|
          memo[row[result.fields.index('View')]] << row[result.fields.index('Dependency')]
        end
      end

      # returns a list of views in the current database
      private def view_names
        execute('SHOW FULL TABLES WHERE table_type = "VIEW"')
          .map(&:first)
      end

      # returns the SELECT used to create the view
      private def view_definition(name)
        execute("SHOW CREATE VIEW #{quote_table_name(name)}")
          .first[1]
          .sub(/\A.*#{quote_table_name(name)} AS /i, '')
          .gsub(/#{quote_table_name(@connectable.connection.current_database)}\./, '')
      end
    end
  end
end
