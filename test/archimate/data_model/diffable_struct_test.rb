# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DiffableStructTest < Minitest::Test
      def setup
        @base = build_model(with_relationships: 2, with_diagrams: 1)
        @diagram = @base.diagrams.first
        @remote_diagram = @diagram.with(name: "I wuz renamed")
        @local = @base.with(name: @base.name + "changed")
        @remote = @base.with(
          diagrams: @base.diagrams.map do |i|
            @diagram.id == i.id ? @remote_diagram : i
          end
        )
        assert @remote.diagrams.any? { |d| d.name == "I wuz renamed" }
      end

      def test_diff_on_primitive_attribute
        assert_equal(
          [Diff::Change.new(@diagram, @remote_diagram, "name")].map(&:to_s),
          @diagram.diff(@remote_diagram).map(&:to_s)
          # @base.diff(@remote).map(&:to_s)
        )
      end

      def test_diff_on_insert
        assert_equal(
          [Diff::Delete.new(@base)],
          @base.diff(nil)
        )
      end

      def test_primitive
        refute @base.primitive?
      end

      def test_delete
        subject = @base.clone.delete("name", @base.name)

        refute @base.name.nil?
        assert subject.name.nil?
      end

      def test_insert
        base = build_bounds(x: nil)
        subject = base.clone
        assert_nil subject.x

        subject.insert("x", 3.14)

        assert base.x.nil?
        assert_equal 3.14, subject.x
      end

      def test_change
        base = build_bounds(x: 1.0)
        subject = base.clone

        subject.change("x", 1.0, 3.14)

        assert_equal 1.0, base.x
        assert_equal 3.14, subject.x
      end
    end
  end
end
