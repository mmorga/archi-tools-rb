# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Svg
    class PathTest < Minitest::Test
      def setup
        @connection = build_connection(
            relationship: nil,
            source: build_view_node(
                bounds: DataModel::Bounds.new(x: 0, y: 0, width: 10, height: 10)
              ),
            target: build_view_node(
                bounds: DataModel::Bounds.new(x: 100, y: 0, width: 10, height: 10)
              )
          )
        @subject = Path.new(@connection)
      end

      def test_subject
        assert_equal DataModel::Bounds.new(x: 0, y:0, width: 10, height: 10), @connection.source.bounds
        assert_equal DataModel::Bounds.new(x: 100, y:0, width: 10, height: 10), @connection.target.bounds
      end

      def test_length
        assert_equal 90.0, @subject.length
      end

      def test_points
        assert_equal [Point.new(10.0, 5.0), Point.new(100.0, 5.0)], @subject.points
      end

      def test_segment_lengths
        assert_equal [90.0], @subject.segment_lengths
      end

      def test_midpoint
        assert_equal Point.new(55.0, 5.0), @subject.midpoint
      end
    end
  end
end
