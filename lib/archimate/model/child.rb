module Archimate
  module Model
    class Child < Dry::Struct::Value
      attribute :id, Types::Strict::String
      attribute :type, Types::Strict::String.optional
      attribute :text_alignment, Types::Strict::String.optional
      attribute :fill_color, Types::Strict::String.optional
      attribute :model, Types::Strict::String.optional
      attribute :name, Types::Strict::String.optional
      attribute :target_connections, Types::Strict::String.optional
      attribute :archimate_element, Types::Strict::String.optional
      attribute :font, Types::Strict::String.optional
      attribute :line_color, Types::Strict::String.optional
      attribute :font_color, Types::Strict::String.optional
      attribute :bounds, Types::OptionalBounds
      attribute :children, Types::Strict::Hash
      attribute :source_connections, Types::SourceConnectionList

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
