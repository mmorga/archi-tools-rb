# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffableArray
      using DiffablePrimitive

      refine Array do
        using DiffablePrimitive

        def diff(other)
          return [Diff::Delete.new(Archimate.node_reference(self))] if other.nil?
          raise TypeError, "Expected other #{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
          return [] if self == other

          result = []
          my_idx = 0
          other_idx = 0

          while my_idx < size
            if at(my_idx) == other[other_idx]
              my_idx += 1
              other_idx += 1
              next
            elsif at(my_idx).id == other[other_idx].id
              result.concat(at(my_idx).diff(other[other_idx]))
              my_idx += 1
              other_idx += 1
            elsif other[other_idx + 1..-1]&.smart_include?(at(my_idx))
              if self[my_idx + 1..-1].smart_include?(other[other_idx])
                # TODO: Handle a move diff here other[other_idx] was moved elsewhere
              else
                result << Diff::Insert.new(Archimate.node_reference(other, other[other_idx]))
              end
              other_idx += 1
            else
              if other_idx >= other.size || self[my_idx + 1..-1].smart_include?(other[other_idx])
                result << Diff::Delete.new(Archimate.node_reference(self, self[my_idx]))
                my_idx += 1
              else
                result.concat(diff_items(my_idx, other, other_idx))
                my_idx += 1
                other_idx += 1
              end
            end
          end

          while other_idx < other.size
            result << Diff::Insert.new(Archimate.node_reference(other, other[other_idx]))
            other_idx += 1
          end

          result
        end

        def diff_items(my_idx, other, other_idx)
          if self[my_idx].primitive?
            Diff::Change.new(
              Archimate.node_reference(other, other_idx),
              Archimate.node_reference(self, my_idx)
            )
          else
            self[my_idx].diff(other[other_idx])
          end
        end

        def smart_include?(val)
          case val
          when IdentifiedNode
            any? { |item| item.id == val.id }
          else
            include?(val)
          end
        end

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

        def build_index(hash_index = {})
          hash_index[object_id] = self
          reduce(hash_index) { |a, e| e.build_index(a) }
        end

        def match(other)
          self == other
        end

        def path(options = {})
          [
            parent&.path(options),
            parent&.attribute_name(self, options)
          ].compact.reject(&:empty?).join("/")
        end

        def attribute_name(child, options = {})
          if child.is_a?(IdentifiedNode) && options.fetch(:force_array_index, :id) == :id
            child.id
          else
            find_index(child)
          end
        end

        def primitive?
          false
        end

        def delete(idx, value)
          raise(ArgumentError, "idx was blank") if idx.nil?
          super(value)
          self
        end

        def insert(idx, value)
          ary_idx =
            case value
            when IdentifiedNode
              find_index { |item| item.id == value.id } || size
            else
              idx.to_i
            end
          super(ary_idx, value)
          self
        end

        def change(idx, from_value, to_value)
          raise(ArgumentError, "idx was blank") if idx.nil?
          ary_idx =
            case to_value
            when IdentifiedNode
              find_index { |item| item.id == from_value.id }
            else
              index(from_value)
            end
          self[ary_idx] = to_value
          self
        end

        def clone
          map(&:clone)
        end

        # TODO: this duplicates the same method in ArchimateNode look for opportunity to refactor into common module.
        def ancestors
          result = [self]
          p = self
          result << p until (p = p.parent).nil?
          result
        end

        def to_s
          "#{parent}/#{parent.attribute_name(self)}"
        end

        def referenced_identified_nodes
          reduce([]) do |a, e|
            a.concat(e.referenced_identified_nodes)
          end
        end

        def find_by_id(an_id)
          find { |el| el.id == an_id }
        end
      end
    end
  end
end
