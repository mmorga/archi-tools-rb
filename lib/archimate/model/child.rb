module Archimate
  module Model
    class Child
      attr_accessor :id, :type, :text_alignment, :fill_color, :model, :name,
        :target_connections, :archimate_element, :font, :line_color, :font_color
      attr_accessor :bounds, :children, :source_connection

      def initialize(id)
        @id = id
        yield self if block_given?
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
