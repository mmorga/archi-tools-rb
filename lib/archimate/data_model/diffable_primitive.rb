# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffablePrimitive
      module DiffablePrimitiveMethods
        def diff(other)
          return [Archimate::Diff::Delete.new("path_str", nil, self)] if other.nil?
          return [Archimate::Diff::Change.new("path_str", nil, nil, self, other)] unless self == other
          []
        end

        def assign_model(_m)
        end

        def assign_parent(_p)
        end

        def match(other)
          self == other
        end

        def primitive
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
