module Archimate
  module Model
    class Child < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :type, Archimate::Types::Coercible::String
      attribute :text_alignment, Archimate::Types::Coercible::String
      attribute :fill_color, Archimate::Types::Coercible::String
      attribute :model, Archimate::Types::Coercible::String
      attribute :name, Archimate::Types::Coercible::String
      attribute :target_connections, Archimate::Types::Coercible::String
      attribute :archimate_element, Archimate::Types::Coercible::String
      attribute :font, Archimate::Types::Coercible::String
      attribute :line_color, Archimate::Types::Coercible::String
      attribute :font_color, Archimate::Types::Coercible::String
      attribute :bounds, Archimate::Types::OptionalBounds
      attribute :children, Archimate::Types::Coercible::Array
      attribute :source_connections, Archimate::Types::Coercible::Array

      def self.create(options = {})
        new_opts = {
          type: nil,
          text_alignment: nil,
          fill_color: nil,
          model: nil,
          name: nil,
          target_connections: nil,
          archimate_element: nil,
          font: nil,
          line_color: nil,
          font_color: nil,
          bounds: nil,
          children: {},
          source_connections: []
        }.merge(options)
        Child.new(new_opts)
      end
    end
  end
end

# Type is one of:  ["archimate:DiagramModelReference", "archimate:Group", "archimate:DiagramObject"]
# textAlignment "2"
# model is on only type of archimate:DiagramModelReference and is id of another element type=archimate:ArchimateDiagramModel
# fillColor, lineColor, fontColor are web hex colors
# targetConnections is a string of space separated ids to connections on diagram objects found on DiagramObject
# archimateElement is an id of a model element found on DiagramObject types
# font is of this form: font="1|Arial|14.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial"
