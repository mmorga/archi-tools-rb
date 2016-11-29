# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffableArray
      using DiffablePrimitive

      refine Array do
        using DiffablePrimitive

        def diff(other)
          diff_list = []
          base_idx = 0
          local_idx = 0
          while base_idx < size || local_idx < other.size
            if base_idx >= size
              until local_idx >= other.size
                diff_list << Diff::Insert.new("[#{local_idx}]", other.in_model, other[local_idx])
                local_idx += 1
              end
            elsif local_idx >= other.size
              until base_idx >= size
                diff_list << Diff::Delete.new("[#{base_idx}]", in_model, self[base_idx])
                base_idx += 1
              end
            elsif self[base_idx] == other[local_idx]
              base_idx += 1
              local_idx += 1
            elsif self[base_idx].match(other[local_idx])
              self[base_idx].diff(other[local_idx])
              base_idx += 1
              local_idx += 1
            elsif other[local_idx + 1..-1].any? { |i| self[base_idx].match(i) }
              diff_list << Diff::Insert.new("[#{base_idx}]", other[local_idx].in_model, other[local_idx])
              local_idx += 1
            else
              diff_list << Diff::Delete.new("[#{base_idx}]", in_model, self[base_idx])
              base_idx += 1
            end
          end
          diff_list.flatten
        end

        def assign_model(m)
          @in_model = m
          each { |i| i.assign_model(m) }
        end

        def assign_parent(p)
          @parent = p
          each { |i| i.assign_parent(self) }
        end

        def in_model
          @in_model if defined?(@in_model)
        end

        def parent
          @parent if defined?(@parent)
        end

        def match(other)
          self == other
        end
      end
    end
  end
end
