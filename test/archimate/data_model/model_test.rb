# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ModelTest < Minitest::Test
      ELEMENT_COUNT = 4

      def setup
        @subject = build_model(with_relationships: 2, with_diagrams: 2, with_elements: ELEMENT_COUNT, with_folders: 4)
      end

      def test_build_model
        assert_equal 4, @subject.elements.size
        assert_equal 2, @subject.relationships.size
        assert_equal 2, @subject.diagrams.size
      end

      def test_equality_operator
        m2 = @subject.clone
        assert_equal @subject, m2
      end

      def test_equality_operator_false
        m2 = @subject.with(name: "felix")
        refute_equal @subject, m2
      end

      def test_lookup
        @subject.relationships.each { |r| assert_equal r, @subject.lookup(r.id) }
        @subject.elements.each { |e| assert_equal e, @subject.lookup(e.id) }
        @subject.folders.each { |f| assert_equal f, @subject.lookup(f.id) }
        @subject.diagrams.each do |d|
          assert_equal d, @subject.lookup(d.id)
          refute d.children.empty?
          d.children.each do |c|
            assert_equal c, @subject.lookup(c.id)
            c.source_connections.each do |s|
              assert_equal s, @subject.lookup(s.id)
            end
          end
        end
      end

      def test_clone
        s2 = @subject.clone
        assert_equal @subject, s2
        refute_equal @subject.object_id, s2.object_id
      end

      def test_application_components
        el = build_element(type: "ApplicationComponent")
        elements = @subject.elements + [el]
        model = @subject.with(elements: elements)
        expected = model.elements.select { |e| e.type == "ApplicationComponent" }

        assert_equal expected, model.application_components
      end

      def test_property_keys
        assert [], @subject.property_keys
      end

      def test_find_by_class
        assert_equal [@subject], @subject.find_by_class(Model)
        assert_equal @subject.elements, @subject.find_by_class(Element)
      end
    end
  end
end
