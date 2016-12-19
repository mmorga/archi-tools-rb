# frozen_string_literal: true
module Archimate
  module DataModel
    class Relationship < IdentifiedNode
      attribute :name, Strict::String.optional
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :access_type, Coercible::Int.optional # TODO: turn this into an enum

      def to_s
        HighLine.color(
          "#{AIO.data_model(type)}<#{id}>[#{HighLine.color(name || '', [:black, :underline])}]",
          :on_light_magenta
        ) + " #{source} -> #{target}"
      end

      def referenced_identified_nodes
        [@source, @target].compact
      end
    end
    Dry::Types.register_class(Relationship)
  end
end
