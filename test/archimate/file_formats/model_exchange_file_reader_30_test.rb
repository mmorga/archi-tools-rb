# frozen_string_literal: true
require 'test_helper'
require 'test_examples'

module Archimate
  module FileFormats
    class ModelExchangeFileReader30Test < Minitest::Test
      attr_accessor :model

      def setup
        @model = model_exchange_archisurance_30_model
      end

      def test_model_simple_attributes
        assert_equal DataModel::LangString.new(lang_hash: {"en" => "ArchiSurance V3"}, default_lang: "en", default_text: "ArchiSurance V3"), model.name
        assert_equal "id-LK_OS_TEMPLATE_SYSARCH_Testing_ArchiMate_3.0_Configuration", model.id
      end

      def test_model_documentation
        assert_equal 1, model.documentation.size
        assert_equal(
          DataModel::LangString.new(lang_hash: {"en" => "An example of a fictional Insurance company."}, default_lang: "en", default_text: "An example of a fictional Insurance company."),
          model.documentation
        )
      end

      def test_model_properties
        assert_equal 0, model.properties.size
      end

      def test_model_elements
        assert_equal 119, model.elements.size
        assert_equal(
          DataModel::Element.new(
            id: "id-4927",
            type: "BusinessActor",
            name: DataModel::LangString.new(lang_hash: {"en" => "Client"}, default_lang: "en", default_text: "Client")
          ), model.elements.first
        )
        assert_equal(
          DataModel::Element.new(
            id: "id-5010",
            type: "Principle",
            name: DataModel::LangString.new(lang_hash: {"en" => "Client Satisfaction Goal"}, default_lang: "en", default_text: "Client Satisfaction Goal")
          ), model.elements.last
        )
      end

      def test_model_relationships
        assert_equal 179, model.relationships.size
        assert_equal(
          DataModel::Relationship.new(
            id: "id-4948-110-4942",
            source: model.lookup("id-4948"),
            target: model.lookup("id-4942"),
            type: "Specialization",
            name: nil
          ), model.relationships.first
        )
        assert_equal(
          DataModel::Relationship.new(
            id: "id-4903-158-4921",
            source: model.lookup("id-4903"),
            target: model.lookup("id-4921"),
            type: "Association",
            name: nil
          ), model.relationships.last
        )
      end

      def test_organizations
        organizations = model.organizations
        assert_equal 0, organizations.size
      end

      def test_diagrams
        assert_equal 17, model.diagrams.size
        d = model.diagrams[1]

        assert_equal "Layered View", d.name.to_s
        assert_equal "id-5584", d.id
        assert_equal "Layered", d.viewpoint_type
        assert_equal 7, d.nodes.size
        assert_equal 28, d.connections.size
      end
    end
  end
end
