# frozen_string_literal: true
module Archimate
  module DataModel
    class Relationship < IdentifiedNode
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :access_type, Coercible::Int.optional # TODO: turn this into an enum

      def to_s
        HighLine.color(
          "#{AIO.data_model(type)}<#{id}>[#{HighLine.color(name&.strip || '', [:black, :underline])}]",
          :on_light_magenta
        ) + " #{source_element} -> #{target_element}"
      end

      def description
        [
          name.nil? ? nil : "#{name}:",
          FileFormats::ArchimateV2::RELATION_VERBS.fetch(type, nil)
        ].compact.join(" ")
      end

      def referenced_identified_nodes
        [@source, @target].compact
      end

      def source_element
        element_by_id(source)
      end

      def target_element
        element_by_id(target)
      end

      # Diagrams that this element is referenced in.
      def diagrams
        @diagrams ||= in_model.diagrams.select do |diagram|
          diagram.relationship_ids.include?(id)
        end
      end
    end
    Dry::Types.register_class(Relationship)
  end
end
