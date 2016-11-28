# frozen_string_literal: true

module Archimate
  module FileFormats
    class Writer
      attr_reader :model

      def self.write(model, output_io)
        writer = new(model)
        writer.write(output_io)
      end

      def initialize(model)
        @model = model
      end

      def serialize(xml, collection)
        Array(collection).each do |item|
          case item
          when DataModel::Bendpoint
            serialize_bendpoint(xml, item)
          when DataModel::Bounds
            serialize_bounds(xml, item)
          when DataModel::Child
            serialize_child(xml, item)
          when DataModel::Color
            serialize_color(xml, item)
          when DataModel::Diagram
            serialize_diagram(xml, item)
          when DataModel::Documentation
            serialize_documentation(xml, item)
          when DataModel::Element
            serialize_element(xml, item)
          when DataModel::Folder
            serialize_folder(xml, item)
          when DataModel::Font
            serialize_font(xml, item)
          when DataModel::Model
            serialize_model(xml, item)
          when DataModel::Property
            serialize_property(xml, item)
          when DataModel::Relationship
            serialize_relationship(xml, item)
          when DataModel::SourceConnection
            serialize_source_connection(xml, item)
          when DataModel::Style
            serialize_style(xml, item)
          else
            raise TypeError, "Unexpected item type #{item.class}"
          end
        end
      end

      def remove_nil_values(h)
        h.delete_if { |_k, v| v.nil? }
      end
    end
  end
end
