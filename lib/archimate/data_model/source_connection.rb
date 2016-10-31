# frozen_string_literal: true
module Archimate
  module DataModel
    class SourceConnection < Dry::Struct
      include DataModel::With

      attribute :id, Strict::String
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :relationship, Strict::String.optional
      attribute :name, Strict::String.optional
      attribute :type, Strict::String.optional
      attribute :bendpoints, BendpointList
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :style, OptionalStyle

      def self.create(options = {})
        new_opts = {
          relationship: nil,
          name: nil,
          bendpoints: [],
          documentation: [],
          properties: [],
          style: nil,
          type: nil

        }.merge(options)
        SourceConnection.new(new_opts)
      end

      def clone
        SourceConnection.new(
          id: id.clone,
          source: source.clone,
          target: target.clone,
          relationship: relationship.nil? ? nil : relationship.clone,
          name: name.nil? ? nil : name.clone,
          type: type.nil? ? nil : type.clone,
          bendpoints: bendpoints.map(&:clone),
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          style: style.nil? ? nil : style.clone
        )
      end

      def type_name
        "#{'SourceConnection'.blue.italic}[#{(name || '').black.underline}]".on_light_magenta
      end

      def describe(model)
        s = model.elements[source]
        t = model.elements[target]
        "#{type_name} #{s.nil? ? 'nothing' : s.short_desc}->#{t.nil? ? 'nothing' : t.short_desc}"
      end
    end
    Dry::Types.register_class(SourceConnection)
    SourceConnectionList = Strict::Array.member("archimate.data_model.source_connection")
  end
end
