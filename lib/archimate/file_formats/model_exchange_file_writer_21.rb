# frozen_string_literal: true

require "nokogiri"

module Archimate
  module FileFormats
    REL_NAME_MAPPING = {
      DataModel::Relationships::Realization => "Realisation",
      DataModel::Relationships::Serving => "UsedBy",
      DataModel::Relationships::Specialization => "Specialisation"
    }.freeze

    # Archimate version 2.1 Model Exchange Format Writer
    class ModelExchangeFileWriter21 < Serializer::ModelExchangeFile::ModelExchangeFileWriter
      include Serializer::ModelExchangeFile::V21::Connection
      include Serializer::ModelExchangeFile::V21::Diagram
      include Serializer::ModelExchangeFile::Element
      include Serializer::ModelExchangeFile::V21::Item
      include Serializer::ModelExchangeFile::V21::Label
      include Serializer::ModelExchangeFile::Location
      include Serializer::ModelExchangeFile::V21::Model
      include Serializer::ModelExchangeFile::Organization
      include Serializer::ModelExchangeFile::V21::OrganizationBody
      include Serializer::ModelExchangeFile::V21::Property
      include Serializer::ModelExchangeFile::Properties
      include Serializer::ModelExchangeFile::Relationship
      include Serializer::ModelExchangeFile::Style
      include Serializer::ModelExchangeFile::V21::ViewNode
      include Serializer::ModelExchangeFile::V21::Viewpoint

      def initialize(model)
        super
      end

      def relationship_attributes(relationship)
        rel_name = REL_NAME_MAPPING.fetch(relationship.class, relationship.type)
        {
          identifier: identifier(relationship.id),
          source: identifier(relationship.source.id),
          target: identifier(relationship.target.id),
          "xsi:type" => "#{rel_name}Relationship"
        }
      end

      def font_style_string(font)
        font&.style_string
      end

      def meff_type(el_type)
        case el_type
        when 'AndJunction', 'OrJunction'
          'Junction'
        else
          el_type
        end
      end
    end
  end
end
