# frozen_string_literal: true
module Archimate
  module DataModel
    module Membership
      using DiffablePrimitive

      def assign_model(model)
        @in_model = model
        each { |item| item.assign_model(model) }
      end

      def in_model
        @in_model if defined?(@in_model)
      end

      def assign_parent(par)
        @parent = par
        each { |i| i.assign_parent(self) }
      end

      def parent
        @parent if defined?(@parent)
      end

      def id
        object_id
      end

      # TODO: this duplicates the same method in ArchimateNode look for opportunity to refactor into common module.
      def ancestors
        result = [self]
        p = self
        result << p until (p = p.parent).nil?
        result
      end

      def build_index(hash_index = {})
        hash_index[id] = self
        each_with_object(hash_index) { |i, a| i.primitive? ? a[i.object_id] = i : i.build_index(a) }
      end

      def referenced_identified_nodes
        reduce([]) do |a, e|
          a.concat(e.referenced_identified_nodes)
        end
      end

      def path(options = {})
        [
          parent&.path(options),
          parent&.attribute_name(self, options)
        ].compact.reject(&:empty?).join("/")
      end

      def primitive?
        false
      end
    end
  end
end
