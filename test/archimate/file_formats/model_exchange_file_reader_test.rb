# frozen_string_literal: true
require 'test_helper'

module Archimate
  module FileFormats
    class ModelExchangeFileReaderTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = MODEL_EXCHANGE_ARCHISURANCE_MODEL
      end

      def test_model_simple_attributes
        assert_equal "Archisurance", model.name
        assert_equal "11f5304f", model.id
      end

      def test_model_documentation
        assert_equal 1, model.documentation.size
        assert_equal(
          DataModel::Documentation.new(text: "An example of a fictional Insurance company.", lang: "en"),
          model.documentation.first
        )
      end

      def test_model_properties
        assert_equal 2, model.properties.size
        assert_equal(
          DataModel::Property.new(key: "Property1", value: "Value of Property 1", lang: "en"),
          model.properties.first
        )
        assert_equal(
          DataModel::Property.new(key: "Property2", value: "Value of Property 2", lang: "en"),
          model.properties.last
        )
      end

      def test_model_elements
        assert_equal 120, model.elements.size
        assert_equal(
          DataModel::Element.create(
            id: "1544",
            type: "BusinessInterface",
            label: "mail"
          ), model.elements.first
        )
        assert_equal(
          DataModel::Element.create(
            id: "3db08b5c",
            type: "Principle",
            label: "Infrastructure Principle"
          ), model.elements.last
        )
      end

      def test_model_relationships
        assert_equal 178, model.relationships.size
        assert_equal(
          DataModel::Relationship.create(
            id: "693",
            source: "564",
            target: "674",
            type: "AccessRelationship",
            name: "create/ update"
          ), model.relationships.first
        )
        assert_equal(
          DataModel::Relationship.create(
            id: "dd9c00de",
            source: "1101",
            target: "1882",
            type: "AssociationRelationship",
            name: nil
          ), model.relationships.last
        )
      end

      def test_folders
        folders = model.folders
        assert_equal 6, folders.size
        assert folders.all? { |e| e.is_a? DataModel::Folder }
      end

      def test_diagrams
        assert_equal 17, model.diagrams.size
        d = model.diagrams[1]

        assert_equal "Layered View", d.name
        assert_equal "4056", d.id
        assert_equal "Layered", d.viewpoint
        assert_equal 7, d.children.size
        assert_equal 28, d.source_connections.size
      end
    end
  end
end
