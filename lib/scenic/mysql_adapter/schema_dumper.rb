# This code is needed to support SQL views in MySQL in Rails < 5.1
# if you want to continue using 'db/schema.rb' instead of migrating to
# the SQL version 'db/structure.sql'.
#
# The problem is that, when you execute "SHOW TABLES" in MySQL, any
# view that you hava created also shows in that list.
#
# So when you create a view, when the 'db/schema.rb' file is updated,
# the view appears twice: first as a table, then as a view.
#
# As of this writing, the latest 5.x versions of Rails filter out
# views when providing the list of tables, so this problem doesn't
# appear. But for previous versions it's still there.
#
# This code patches the method SchemaDumper#table which is in charge
# of dumping a table to the 'db/schema.rb' file when it's being updated
# and does nothing when the supplied table is actually a view.
#
# This module needs to be prepended to ActiveRecord::SchemaDumper for
# the patch to work. See 'adapters/railtie.rb'

require "rails"
require_relative '../adapters/my_sql'

module Scenic
  module Adapters
    module MySql
      module SchemaDumper
        def table(table, stream)
          return if defined_views.any? { |v| v.name == table } # Ignore tables that are views
          super
        end

        private

        def defined_views
          @defined_views ||= Scenic.database.views
        end
      end
    end
  end
end
