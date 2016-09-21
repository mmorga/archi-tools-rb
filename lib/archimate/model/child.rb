module Archimate
  module Model
    class Child
      attr_reader :id
      attr_accessor :type, :text_alignment, :fill_color, :model, :name
      attr_accessor :target_connections, :archimate_element, :font, :line_color
      attr_accessor :font_color, :bounds, :children, :source_connection

      def initialize(id)
        @id = id
        @type = nil
        @text_alignment = nil
        @fill_color = nil
        @model = nil
        @name = nil
        @target_connections = nil
        @archimate_element = nil
        @font = nil
        @line_color = nil
        @font_color = nil
        @bounds = nil
        @children = {}
        @source_connection = nil
        yield self if block_given?
      end

      def ==(other)
        @id == other.id &&
          @type == other.type &&
          @text_alignment == other.text_alignment &&
          @fill_color == other.fill_color &&
          @model == other.model &&
          @name == other.name &&
          @target_connections == other.target_connections &&
          @archimate_element == other.archimate_element &&
          @font == other.font &&
          @line_color == other.line_color &&
          @font_color == other.font_color &&
          @bounds == other.bounds &&
          @children == other.children &&
          @source_connection == other.source_connection
      end

      def hash
        self.class.hash ^
          @id ^
          @type ^
          @text_alignment ^
          @fill_color ^
          @model ^
          @name ^
          @target_connections ^
          @archimate_element ^
          @font ^
          @line_color ^
          @font_color ^
          @bounds ^
          @children ^
          @source_connection
      end

      def dup(id: nil)
        Child.new(id || @id) do |c|
          c.type = type.dup
          c.text_alignment = text_alignment.dup
          c.fill_color = fill_color.dup
          c.model = model.dup
          c.name = name.dup
          c.target_connections = target_connections.dup
          c.archimate_element = archimate_element.dup
          c.font = font.dup
          c.line_color = line_color.dup
          c.font_color = font_color.dup
          c.bounds = bounds.dup
          c.children = children.dup
          c.source_connection = source_connection.dup
        end
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
