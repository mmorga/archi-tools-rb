# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileWriter30 < Serializer::ModelExchangeFile::ModelExchangeFileWriter
      include Serializer::ModelExchangeFile::V30::Connection
      include Serializer::ModelExchangeFile::V30::Diagram
      include Serializer::ModelExchangeFile::Element
      include Serializer::ModelExchangeFile::V30::Item
      include Serializer::ModelExchangeFile::V30::Label
      include Serializer::ModelExchangeFile::Location
      include Serializer::ModelExchangeFile::V30::Model
      include Serializer::ModelExchangeFile::Organization
      include Serializer::ModelExchangeFile::V30::OrganizationBody
      include Serializer::ModelExchangeFile::V30::Property
      include Serializer::ModelExchangeFile::Properties
      include Serializer::ModelExchangeFile::Relationship
      include Serializer::ModelExchangeFile::Style
      include Serializer::ModelExchangeFile::V30::ViewNode

      def initialize(model)
        super
      end

      def relationship_attributes(relationship)
        attrs = {
          identifier: identifier(relationship.id),
          source: identifier(relationship.source.id),
          target: identifier(relationship.target.id),
          "xsi:type" => meff_type(relationship.type)
        }
        attrs["accessType"] = relationship.access_type if relationship.access_type
        attrs
      end

      def font_style_string(font)
        case font&.style
        when 1
          "italic"
        when 2
          "bold"
        when 3
          "bold italic"
        end
      end

      def meff_type(el_type)
        el_type.sub(/^/, "")
      end
    end
  end
end
