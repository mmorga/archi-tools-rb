# frozen_string_literal: true
module Archimate
  module DataModel
    class Child < Dry::Struct
      include DataModel::With

      attribute :id, Strict::String
      attribute :type, Strict::String.optional
      attribute :model, Strict::String.optional
      attribute :name, Strict::String.optional
      attribute :target_connections, Strict::String.optional # TODO: this is a list encoded in a string
      attribute :archimate_element, Strict::String.optional
      attribute :bounds, OptionalBounds
      attribute :children, Strict::Hash
      attribute :source_connections, SourceConnectionList
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :style, OptionalStyle

      def self.create(options = {})
        new_opts = {
          type: nil,
          model: nil,
          name: nil,
          target_connections: nil,
          archimate_element: nil,
          bounds: nil,
          children: {},
          source_connections: [],
          documentation: [],
          properties: [],
          style: nil
        }.merge(options)
        Child.new(new_opts)
      end

      def clone
        Child.new(
          id: id.clone,
          type: type.nil? ? nil : type.clone,
          model: model.nil? ? nil : model.clone,
          name: name.nil? ? nil : name.clone,
          target_connections: target_connections.nil? ? nil : target_connections.clone,
          archimate_element: archimate_element.nil? ? nil : archimate_element.clone,
          bounds: bounds.nil? ? nil : bounds.clone,
          children: children.each_with_object({}) { |(k, v), a| a[k] = v.clone },
          source_connections: source_connections.map(&:clone),
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          style: style.nil? ? nil : style.clone
        )
      end

      def element_references
        children.each_with_object([archimate_element]) { |(_id, child), a| a.concat(child.element_references) }
      end

      def relationships
        children.each_with_object(source_connections.map(&:relationship).compact) do |(_id, child), a|
          a.concat(child.relationships)
        end
      end

      def describe(model)
        "Child[#{name || ""}](#{model.elements[archimate_element].short_desc if archimate_element})"
      end
    end

    Dry::Types.register_class(Child)
    ChildHash = Strict::Hash
  end
end

# Type is one of:  ["archimate:DiagramModelReference", "archimate:Group", "archimate:DiagramObject"]
# textAlignment "2"
# model is on only type of archimate:DiagramModelReference and is id of another element type=archimate:ArchimateDiagramModel
# fillColor, lineColor, fontColor are web hex colors
# targetConnections is a string of space separated ids to connections on diagram objects found on DiagramObject
# archimateElement is an id of a model element found on DiagramObject types
# font is of this form: font="1|Arial|14.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial"
