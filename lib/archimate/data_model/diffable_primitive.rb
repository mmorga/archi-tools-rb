# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffablePrimitive
      module DiffablePrimitiveMethods
        def diff(other, from_parent, to_parent, attribute)
          return [Archimate::Diff::Delete.new(from_parent, attribute)] if other.nil?
          raise TypeError, "Expected other #{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
          return [Archimate::Diff::Change.new(from_parent, to_parent, attribute)] unless self == other
          []
        end

        def assign_model(_m)
        end

        def assign_parent(_p)
        end

        def match(other)
          self == other
        end

        def primitive?
          true
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
