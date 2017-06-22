# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of the meta-data element contains data structures that declare descriptive information
    # about a meta-data element's parent only.
    #
    # One or more different meta-data models may be declared as child extensions of a meta-data element.
    class Metadata < ArchimateNode
      attribute :schema_infos, Strict::Array.member(SchemaInfo).default([])
    end
    Dry::Types.register_class(Metadata)
  end
end
