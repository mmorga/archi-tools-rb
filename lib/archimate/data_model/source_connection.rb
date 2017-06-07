# frozen_string_literal: true
module Archimate
  module DataModel
    class SourceConnection < Referenceable
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :relationship, Strict::String.optional
      attribute :bendpoints, BendpointList
      attribute :style, Style.optional
      attribute :properties, PropertiesList # Note: this is not in the model under element
      # it's added under Real Element

      def replace(entity, with_entity)
        @relationship = with_entity.id if (relationship == entity.id)
        @source = with_entity.id if (source == entity.id)
        @target = with_entity.id if (target == entity.id)
      end

      def type_name
        Archimate::Color.color("#{Archimate::Color.data_model('SourceConnection')}[#{Archimate::Color.color(@name || '', [:white, :underline])}]", :on_light_magenta)
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
    end
    Dry::Types.register_class(SourceConnection)
    SourceConnectionList = Strict::Array.member("archimate.data_model.source_connection").default([])
  end
end
