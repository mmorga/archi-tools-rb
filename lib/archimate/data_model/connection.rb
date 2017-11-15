# frozen_string_literal: true

module Archimate
  module DataModel
    # Graphical connection type.
    #
    # If the 'relationshipRef' attribute is present, the connection should
    # reference an existing ArchiMate relationship.
    #
    # If the connection is an ArchiMate relationship type, the connection's
    # label, documentation and properties may be determined (i.e inherited)
    # from those in the referenced ArchiMate relationship. Otherwise the
    # connection's label, documentation and properties can be provided and will
    # be additional to (or over-ride) those contained in the referenced
    # ArchiMate relationship.
    class Connection
      include Comparison
      include Referenceable

      # @!attribute [r] id
      # @return [String]
      model_attr :id
      # @!attribute [r] name
      # @return [LangString, NilClass]
      model_attr :name, default: nil
      # @!attribute [r] documentation
      # @return [PreservedLangString, NilClass]
      model_attr :documentation, default: nil
      # # @!attribute [r] other_elements
      # @return [Array<AnyElement>]
      model_attr :other_elements, default: []
      # # @!attribute [r] other_attributes
      # @return [Array<AnyAttribute>]
      model_attr :other_attributes, default: []
      # @note type here was used for the Element/Relationship/Diagram type
      # @!attribute [r] type
      # @return [String, NilClass]
      model_attr :type, default: nil
      # @!attribute [r] source_attachment
      # @return [Location, NilClass]
      model_attr :source_attachment, default: nil
      # @!attribute [r] bendpoints
      # @return [Array<Location>]
      model_attr :bendpoints, default: []
      # @!attribute [r] target_attachment
      # @return [Location, NilClass]
      model_attr :target_attachment, default: nil
      # @!attribute [rw] source
      # @return [ViewNode, NilClass]
      model_attr :source, comparison_attr: :id, writable: true, default: nil
      # @!attribute [rw] target
      # @return [ViewNode, NilClass]
      model_attr :target, comparison_attr: :id, writable: true, default: nil
      # @!attribute [rw] relationship
      # @return [Relationship, NilClass]
      model_attr :relationship, comparison_attr: :id, writable: true, default: nil, also_reference: [:diagram]
      # @!attribute [r] style
      # @return [Style, NilClass]
      model_attr :style, default: nil
      # @!attribute [r] properties
      # @return [Array<Property>]
      model_attr :properties, default: []

      # @!attribute [r] diagram
      # @return [Diagram, NilClass]
      model_attr :diagram, comparison_attr: :no_compare

      def replace(entity, with_entity)
        @relationship = with_entity.id if relationship == entity.id
        @source = with_entity.id if source == entity.id
        @target = with_entity.id if target == entity.id
      end

      def type_name
        Archimate::Color.color("#{Archimate::Color.data_model('Connection')}[#{Archimate::Color.color(@name || '', %i[white underline])}]", :on_light_magenta)
      end

      def element
        relationship
      end

      def to_s
        "#{type_name} #{source.nil? ? 'nothing' : source} -> #{target.nil? ? 'nothing' : target}"
      end

      def description
        [
          name.nil? ? nil : "#{name}: ",
          source&.description,
          relationship&.description,
          target&.description
        ].compact.join(" ")
      end

      def referenced_identified_nodes
        [@source, @target, @relationship].compact
      end

      def start_location
        source_attachment || source_bounds.center
      end

      def end_location
        target_attachment || target_bounds.center
      end

      def source_bounds
        source.absolute_position
      end

      def target_bounds
        target.absolute_position
      end

      # This is used when rendering a connection to connection relationship.
      def nodes
        []
      end

      # TODO: Is this true for all or only Archi models?
      def absolute_position
        # offset = bounds || Archimate::DataModel::Bounds.zero
        offset = Archimate::DataModel::Bounds.zero
        el = parent.parent
        while el.respond_to?(:bounds) && el.bounds
          bounds = el.bounds
          offset = offset.with(x: (offset.x || 0) + (bounds.x || 0), y: (offset.y || 0) + (bounds.y || 0))
          el = el.parent.parent
        end
        offset
      end
    end
  end
end
