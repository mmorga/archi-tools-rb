# frozen_string_literal: true
module Archimate
  module DataModel
    # TODO: Should be obsolete at this point pending Diff re-write
    module DiffablePrimitive
      module DiffablePrimitiveMethods
        def diff(other, from_parent, to_parent, attribute, from_attribute = nil)
          from_attribute = attribute if from_attribute.nil?
          if other.nil?
            return [Diff::Delete.new(
              Diff::ArchimateNodeAttributeReference.new(from_parent, attribute)
            )]
          end
          raise TypeError, "Expected other #{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
          unless self == other
            return [Diff::Change.new(
              Diff::ArchimateNodeReference.for_node(to_parent, attribute),
              Diff::ArchimateNodeReference.for_node(from_parent, from_attribute)
            )]
          end
          []
        end

        def in_model=(_m); end

        def parent=(_p); end

        def parent_attribute_name=(_attr_name); end

        def build_index(index_hash)
          index_hash
        end

        def primitive?
          true
        end

        def id
          object_id.to_s
        end

        def clone
          self
        end

        def dup
          self
        end

        def compact!
          self
        end

        def referenced_identified_nodes
          []
        end
      end

      refine Symbol do
        include DiffablePrimitiveMethods
      end

      refine String do
        include DiffablePrimitiveMethods
      end

      refine Hash do
        include DiffablePrimitiveMethods
      end

      refine Integer do
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
