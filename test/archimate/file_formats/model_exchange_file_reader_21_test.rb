# frozen_string_literal: true
require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ModelExchangeFileReader21Test < Minitest::Test
      attr_accessor :model

      def setup
        @model = model_exchange_archisurance_model
      end

      def test_model_simple_attributes
        assert_equal DataModel::LangString.new(lang_hash: { "en" => "Archisurance"}, default_lang: "en", default_text: "Archisurance"), model.name
        assert_equal "id-11f5304f", model.id
      end

      def test_model_documentation
        assert_equal("An example of a fictional Insurance company.", model.documentation.to_s)
      end

      def test_model_properties
        assert_equal 2, model.properties.size
        pd1 = model.properties.first.property_definition
        assert_equal(
          DataModel::Property.new(
            property_definition: pd1,
            value: DataModel::LangString.new(lang_hash: { "en" => "Value of Property 1"}, default_lang: "en", default_text: "Value of Property 1")
          ),
          model.properties.first
        )
        pd2 = model.properties.last.property_definition
        assert_equal(
          DataModel::Property.new(
            property_definition: pd2,
            value: DataModel::LangString.new(lang_hash: { "en" => "Value of Property 2"}, default_lang: "en", default_text: "Value of Property 2")
          ),
          model.properties.last
        )
      end

      def test_model_elements
        assert_equal 120, model.elements.size
        assert_equal(
          DataModel::Element.new(
            id: "id-1544",
            type: "BusinessInterface",
            name: DataModel::LangString.new(lang_hash: {"en" => "mail"}, default_lang: "en", default_text: "mail")
          ), model.elements.first
        )
        assert_equal(
          DataModel::Element.new(
            id: "id-3db08b5c",
            type: "Principle",
            name: DataModel::LangString.new(lang_hash: {"en" => "Infrastructure Principle"}, default_lang: "en", default_text: "Infrastructure Principle")
          ), model.elements.last
        )
      end

      def test_model_relationships
        assert_equal 178, model.relationships.size
        assert_equal(
          DataModel::Relationship.new(
            id: "id-693",
            source: model.lookup("id-564"),
            target: model.lookup("id-674"),
            type: "AccessRelationship",
            name: DataModel::LangString.new(lang_hash: {"en" => "create/ update"}, default_lang: "en", default_text: "create/ update")
          ), model.relationships.first
        )
        assert_equal(
          DataModel::Relationship.new(
            id: "id-dd9c00de",
            source: model.lookup("id-1101"),
            target: model.lookup("id-1882"),
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
        assert_equal "Layered", d.viewpoint_type
        assert_equal 7, d.nodes.size
        assert_equal 28, d.connections.size
      end
    end
  end
end
