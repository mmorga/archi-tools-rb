# frozen_string_literal: true

module Archimate
  module DataModel
    # Something that can be referenced by another entity.
    module Referenceable
      def add_reference(referencer)
        references << referencer unless references.include?(referencer)
      end

      def remove_reference(referencer)
        references.delete(referencer)
      end

      def references
        @referenceable_set ||= []
      end

      # Diagrams that this entity is referenced in.
      def diagrams
        references.select { |ref| ref.is_a?(Diagram) }
      end
    end
  end
end
