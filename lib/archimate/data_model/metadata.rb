# frozen_string_literal: true

module Archimate
  module DataModel
    # An instance of the meta-data element contains data structures that declare descriptive information
    # about a meta-data element's parent only.
    #
    # One or more different meta-data models may be declared as child extensions of a meta-data element.
    class Metadata
      include Comparison

      # @!attribute [r] schema_infos
      #   @return [Array<SchemaInfo>]
      model_attr :schema_infos

      def initialize(schema_infos: [])
        @schema_infos = schema_infos
      end
    end
  end
end
