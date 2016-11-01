# frozen_string_literal: true
module Archimate
  module DataModel
    class Element < Dry::Struct
      include DataModel::With

      attribute :id, Strict::String
      attribute :type, Strict::String.optional
      attribute :label, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList

      alias name label

      def self.create(options = {})
        new_opts = {
          type: nil,
          label: nil,
          documentation: [],
          properties: []
        }.merge(options)
        Element.new(new_opts)
      end

      def clone
        Element.new(
          id: id.clone,
          type: type.nil? ? nil : type.clone,
          label: label.nil? ? nil : label.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone)
        )
      end

      def to_s
        "#{type}<#{id}> #{label} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def colored_by_type(str)
        case layer
        when "Business"
          str.black.on_yellow
        when "Application"
          str.black.on_light_blue
        when "Technology"
          str.black.on_light_green
        when "Motivation"
          str.white.on_blue
        when "Implementation and Migration"
          str.white.on_green
        when "Connectors"
          str.white.on_black
        else
          str.black.on_red
        end
      end

      def short_desc
        colored_by_type "#{type.italic.light_black}<#{id}>[#{label.underline}]"
      end

      def to_id_string
        "#{type}<#{id}>"
      end

      def layer
        Archimate::Constants::ELEMENT_LAYER.fetch(@type, "None")
      end

      def describe(_model)
        short_desc
      end
    end
  end
end