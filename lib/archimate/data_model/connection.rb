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
    #
    # This is ConnectionType in the XSD
    # ViewConceptType > ConnectionType > SourcedConnectionType > Relationship > NestingRelationship
    #                                  > Line
    #                 > ViewNodeType >
    #                                  Label
    #                                  Container > Element
    class Connection < Referenceable # ViewConcept
      using DiffableArray

      attribute :source_attachment, Location.optional
      attribute :bendpoints, LocationList
      attribute :target_attachment, Location.optional
      attribute :source, Identifier.optional
      attribute :target, Identifier.optional
      attribute :type, Strict::String.optional

      # This is under Relationship
      attribute :relationship, Strict::String.optional

      # Note: this is added under ViewConcept
      attribute :style, Style.optional
      attribute :properties, PropertiesList

      def replace(entity, with_entity)
        @relationship = with_entity.id if (relationship == entity.id)
        @source = with_entity.id if (source == entity.id)
        @target = with_entity.id if (target == entity.id)
      end

      def type_name
        Archimate::Color.color("#{Archimate::Color.data_model('Connection')}[#{Archimate::Color.color(@name || '', [:white, :underline])}]", :on_light_magenta)
      end

      def relationship_element
        in_model.lookup(relationship)
      end

      def element
        relationship_element
      end

      def source_element
        in_model.lookup(source)
      end

      def target_element
        in_model.lookup(target)
      end

      def to_s
        if in_model
          s = in_model.lookup(source) unless source.nil?
          t = in_model.lookup(target) unless target.nil?
        else
          s = source
          t = target
        end
        "#{type_name} #{s.nil? ? 'nothing' : s} -> #{t.nil? ? 'nothing' : t}"
      end

      def description
        [
          name.nil? ? nil : "#{name}: ",
          source_element&.description,
          relationship_element&.description,
          target_element&.description
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
    ConnectionList = Strict::Array.member("archimate.data_model.connection").default([])
  end
end
