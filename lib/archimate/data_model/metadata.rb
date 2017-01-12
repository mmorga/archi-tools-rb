# frozen_string_literal: true
module Archimate
  module DataModel
    class Metadata < ArchimateNode
      attribute :schema, DiffableString.default("Dublin Core")
      attribute :schemaversion, DiffableString.default("1.1")
      attribute :data, MetadataItemList

      def to_s
        "#{type.light_black}[#{data.map(&:to_s).join(', ')}]"
      end
    end
    Dry::Types.register_class(Metadata)
  end
end
