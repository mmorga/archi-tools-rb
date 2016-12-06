# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffablePrimitive
      module DiffablePrimitiveMethods
        def diff(other, from_parent, to_parent, attribute)
          return [Archimate::Diff::Delete.new(
            Archimate.node_reference(from_parent, attribute)
          )] if other.nil?
          raise TypeError, "Expected other #{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
          return [Archimate::Diff::Change.new(
            Archimate.node_reference(to_parent, attribute),
            Archimate.node_reference(from_parent, attribute)
          )] unless self == other
          []
        end

        def assign_model(_m)
        end

        def assign_parent(_p)
        end

        def match(other)
          self == other
        end

        def build_index(index_hash)
          index_hash
        end

        def primitive?
          true
        end

        def id
          self
        end

        def clone
          self
        end

        def compact
          self
        end

        def referenced_identified_nodes
          []
        end

        def identified_nodes
          []
        end
      end

      refine String do
        include DiffablePrimitiveMethods
      end

      refine Fixnum do
        include DiffablePrimitiveMethods
      end

      refine Float do
        include DiffablePrimitiveMethods
      end

      refine NilClass do
        include DiffablePrimitiveMethods
      end
    end
  end
end
