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

          while my_idx < size && other_idx < other.size
            if at(my_idx) == other[other_idx]
              # Objects are equal
              my_idx += 1
              other_idx += 1
            elsif at(my_idx).id == other[other_idx].id
              # Objects have the same id
              result.concat(at(my_idx).diff(other[other_idx]))
              my_idx += 1
              other_idx += 1
            elsif other.after(other_idx).smart_include?(at(my_idx))
              # Current item (on my side) is in the rest of the other array
              if after(my_idx).smart_include?(other[other_idx])
                # Current other item is in the rest of my array
                # This means that My Current Item moved to another place in other array
                result << Diff::Change.new(
                  Archimate.node_reference(other, other.smart_find(self[my_idx])),
                  Archimate.node_reference(self, my_idx)
                )
                my_idx += 1
              else
                # Other current item was inserted
                result << Diff::Insert.new(Archimate.node_reference(other, other_idx))
              end
              other_idx += 1
            elsif after(my_idx).smart_include?(other[other_idx]) && !other.smart_include?(at(my_idx))
              result << Diff::Delete.new(Archimate.node_reference(self, my_idx))
              my_idx += 1
            else
              result.concat(diff_items(my_idx, other, other_idx))
              my_idx += 1
              other_idx += 1
            end
          end

          result.concat(
            (my_idx..size - 1).map do |idx|
              puts "Marking deleted at 2" if at(my_idx).is_a?(DataModel::Element) && at(my_idx).id == "194cdb62"
              Diff::Delete.new(Archimate.node_reference(self, idx)) unless other.smart_include?(at(idx))
            end
          ) if my_idx <= size

          result.concat(
            (other_idx..other.size - 1).map { |idx| Diff::Insert.new(Archimate.node_reference(other, idx)) }
          ) if other_idx <= other.size

          result.compact
        end

        def diff_items(my_idx, other, other_idx)
          case self[my_idx]
          when IdentifiedNode
            if self[my_idx].id == other[other_idx].id
              self[my_idx].diff(other[other_idx])
            elsif !other[0..other_idx - 1].smart_include?(self[my_idx])
              [
                Diff::Delete.new(Archimate.node_reference(self, my_idx)),
                Diff::Insert.new(Archimate.node_reference(other, other_idx))
              ]
            else
              []
            end
          when ArchimateNode
            self[my_idx].diff(other[other_idx])
          else
            if after(my_idx).smart_include?(other[other_idx])
              [
                Diff::Delete.new(Archimate.node_reference(self, my_idx))
              ]
            elsif !other[0..other_idx - 1].smart_include?(self[my_idx])
              [
                Diff::Change.new(
                  Archimate.node_reference(other, other_idx),
                  Archimate.node_reference(self, my_idx)
                )
              ]
            else
              []
            end
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

        def id
          object_id
        end

        def build_index(hash_index = {})
          hash_index[id] = self
          each_with_object(hash_index) { |i, a| i.primitive? ? a[i.object_id] = i : i.build_index(a) }
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
            smart_find(child)
          end
        end

        def primitive?
          false
        end

        def delete(idx, value)
          raise(ArgumentError, "value #{value} was not found in array") unless include?(value)
          super(value)
          self
        end

        def insert(idx, value)
          raise(
            ArgumentError, "Invalid index #{idx.inspect} given for Array size #{size}"
          ) unless idx =~ /[0-9a-f]{8}/ || ((idx.is_a?(Fixnum) || idx =~ /\d+/) && idx.to_i >= 0 && idx.to_i <= size)
          raise(
            ArgumentError, "Invalid value type #{value.class}"
          ) unless value.is_a?(ArchimateNode) || (value.is_a?(String) && value =~ /^[0-9a-f]{8}$/)

          ary_idx =
            case value
            when IdentifiedNode
              smart_find(value) || size
            else
              idx.to_i
            end
          super(ary_idx, value)
          self
        end

        def change(idx, from_value, to_value)
          raise(ArgumentError, "idx was blank") if idx.nil?
          raise(ArgumentError, "Invalid index #{idx.inspect} given for Array size #{size}") if idx.negative? || idx >= size
          raise(
            ArgumentError, "Invalid to_value type #{to_value.class}"
          ) unless to_value.is_a?(ArchimateNode) || (to_value.is_a?(String) && to_value =~ /^[0-9a-f]{8}$/)
          self[smart_find(from_value)] = to_value
          self
        end

        def clone
          map(&:clone)
        end

        def dup
          map(&:dup)
        end

        # TODO: this duplicates the same method in ArchimateNode look for opportunity to refactor into common module.
        def ancestors
          result = [self]
          p = self
          result << p until (p = p.parent).nil?
          result
        end

        def to_s
          "#{parent}/#{parent&.attribute_name(self)}"
        end

        def referenced_identified_nodes
          reduce([]) do |a, e|
            a.concat(e.referenced_identified_nodes)
          end
        end

        def find_by_id(an_id)
          find { |el| el.id == an_id }
        end

        def smart_find(val = nil)
          case val
          when IdentifiedNode
            find_index { |item| item.id == val.id }
          else
            find_index(val)
          end
        end

        def after(idx)
          return [] if idx >= size - 1
          self[idx + 1..-1]
        end
      end
    end
  end
end
