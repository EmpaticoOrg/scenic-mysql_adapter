require 'tsort'

module Scenic
  module MySQLAdapter
    class Views
      include TSort
      include Enumerable

      def initialize(views, graph)
        @views = views
        @graph = graph
      end

      def each(&block)
        @views.each(&block)
      end

      alias :tsort_each_node each

      private def tsort_each_child(node)
        @graph[node.name].each do |child_name|
          yield(@views.find { |v| v.name == child_name })
        end
      end
    end
  end
end
