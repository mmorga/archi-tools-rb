# frozen_string_literal: true
require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ModelExchangeFileReaderTest < Minitest::Test
      attr_accessor :model

      def setup
        @model = MODEL_EXCHANGE_ARCHISURANCE_MODEL
      end

      def test_model_simple_attributes
        assert_equal DataModel::LangString.new("Archisurance"), model.name
        assert_equal "id-11f5304f", model.id
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
        pd1 = model.properties.first.property_definition_id
        assert_equal(
          DataModel::Property.new(property_definition_id: pd1, values: [DataModel::LangString.new(text: "Value of Property 1", lang: "en")]),
          model.properties.first
        )
        pd2 = model.properties.last.property_definition_id
        assert_equal(
          DataModel::Property.new(property_definition_id: pd2, values: [DataModel::LangString.new(text: "Value of Property 2", lang: "en")]),
          model.properties.last
        )
      end

      def test_model_elements
        assert_equal 120, model.elements.size
        assert_equal(
          DataModel::Element.new(
            id: "id-1544",
            type: "BusinessInterface",
            name: DataModel::LangString.new(text: "mail", lang: "en")
          ), model.elements.first
        )
        assert_equal(
          DataModel::Element.new(
            id: "id-3db08b5c",
            type: "Principle",
            name: DataModel::LangString.new(text: "Infrastructure Principle", lang: "en")
          ), model.elements.last
        )
      end

      def test_model_relationships
        assert_equal 178, model.relationships.size
        assert_equal(
          DataModel::Relationship.new(
            id: "id-693",
            source: "id-564",
            target: "id-674",
            type: "AccessRelationship",
            name: DataModel::LangString.new(text: "create/ update", lang: "en")
          ), model.relationships.first
        )
        assert_equal(
          DataModel::Relationship.new(
            id: "id-dd9c00de",
            source: "id-1101",
            target: "id-1882",
            type: "AssociationRelationship",
            name: nil
          ), model.relationships.last
        )
      end

      def test_organizations
        organizations = model.organizations
        assert_equal 6, organizations.size
        assert organizations.all? { |e| e.is_a? DataModel::Organization }
      end

      def test_diagrams
        assert_equal 17, model.diagrams.size
        d = model.diagrams[1]

        assert_equal "Layered View", d.name.to_s
        assert_equal "id-4056", d.id
        assert_equal "Layered", d.viewpoint
        assert_equal 7, d.nodes.size
        assert_equal 28, d.connections.size
      end
    end
  end
end
