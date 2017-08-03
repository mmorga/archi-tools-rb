# frozen_string_literal: true

module Archimate
  module DataModel
    # Graphical connection type.
    #
    # If the 'relationshipRef' attribute is present, the connection should reference an existing ArchiMate relationship.
    #
    # If the connection is an ArchiMate relationship type, the connection's label, documentation and properties may be determined
    # (i.e inherited) from those in the referenced ArchiMate relationship. Otherwise the connection's label, documentation and properties
    # can be provided and will be additional to (or over-ride) those contained in the referenced ArchiMate relationship.
    # ViewConceptType
    # - ConnectionType(
    #     sourceAttachment
    #     bendpoint
    #     targetAttachment
    #     source
    #     target)
    class Connection < Dry::Struct # ViewConceptType
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :id, Identifier
      attribute :name, LangString.optional
      attribute :documentation, PreservedLangString.optional.default(nil)
      # attribute :other_elements, Strict::Array.member(AnyElement).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])
      attribute :type, Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      attribute :source_attachment, Location.optional.default(nil)
      attribute :bendpoints, Strict::Array.member(Location).default([])
      attribute :target_attachment, Location.optional.default(nil)
      attribute :source, Dry::Struct.optional.default(nil) # ViewNode
      attribute :target, Dry::Struct.optional.default(nil) # ViewNode
      attribute :relationship, Relationship.optional.default(nil)
      attribute :style, Style.optional.default(nil)
      attribute :properties, Strict::Array.member(Property).default([])

      attr_writer :source
      attr_writer :target
      attr_writer :relationship

      def dup
        raise "no dup dum dum"
      end

      def clone
        raise "no clone dum dum"
      end

      def replace(entity, with_entity)
        @relationship = with_entity.id if (relationship == entity.id)
        @source = with_entity.id if (source == entity.id)
        @target = with_entity.id if (target == entity.id)
      end

      def type_name
        Archimate::Color.color("#{Archimate::Color.data_model('Connection')}[#{Archimate::Color.color(@name || '', [:white, :underline])}]", :on_light_magenta)
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
    Dry::Types.register_class(Connection)
  end
end
