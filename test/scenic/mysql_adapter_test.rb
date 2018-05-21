require "test_helper"

class Scenic::MysqlAdapterTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Scenic::MysqlAdapter::VERSION
  end

  def setup
    @adapter = Scenic::Adapters::MySQL.new
  end

  def teardown
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS numbers'
  end

  def test_create_view
    @adapter.create_view('numbers', 'SELECT 1 AS num')

    view = @adapter.views.find(&named('numbers'))
    assert_equal 'numbers', view.name
    assert_equal 'select 1 as `num`', view.definition.downcase
  end

  def test_replace_view
    @adapter.create_view('numbers', 'SELECT 1 AS num')
    @adapter.replace_view('numbers', 'SELECT 2 AS num')

    view = @adapter.views.find(&named('numbers'))
    assert_equal 'numbers', view.name
    assert_equal 'select 2 as `num`', view.definition.downcase
  end

  def test_drop_view
    @adapter.create_view('numbers', 'SELECT 1 AS num')
    @adapter.drop_view('numbers')

    refute @adapter.views.find(&named('numbers'))
  end

  def test_update_view
    @adapter.create_view('numbers', 'SELECT 1 AS num')
    @adapter.update_view('numbers', 'SELECT 2 AS num')

    view = @adapter.views.find(&named('numbers'))
    assert_equal 'numbers', view.name
    assert_equal 'select 2 as `num`', view.definition.downcase
  end

  def test_create_materialized_view
    @adapter.create_materialized_view('numbers')
    assert false
  rescue Scenic::Adapters::MySQL::FeatureNotSupportedError
    assert true
  else
    assert false
  end

  def test_update_materialized_view
    @adapter.update_materialized_view('numbers')
    assert false
  rescue Scenic::Adapters::MySQL::FeatureNotSupportedError
    assert true
  else
    assert false
  end

  def test_drop_materialized_view
    @adapter.drop_materialized_view('numbers')
    assert false
  rescue Scenic::Adapters::MySQL::FeatureNotSupportedError
    assert true
  else
    assert false
  end

  def test_views
    @adapter.create_view('b', 'select 1 as num')
    @adapter.create_view('a', 'select * from b')
    @adapter.create_view('c', 'select * from a')

    assert_equal ['b', 'a', 'c'], @adapter.views.map(&:name)
  ensure
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS a'
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS b'
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS c'
  end

  def test_views_dont_show_as_tables
    @adapter.create_view('v', 'select 1 as num')
    output = ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, StringIO.new)
    refute_match /create_table\s+\"v\"/i, output.string, "View is dumped as a table in schema.rb"
  ensure
    ActiveRecord::Base.connection.execute 'DROP VIEW IF EXISTS v'
  end

  private def named(name)
    proc { |v| v.name == name }
  end
end
