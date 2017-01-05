# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffableArray
      using DiffablePrimitive

      refine Array do
        using DiffablePrimitive

        attr_writer :parent_attribute_name

        def diff(other)
          raise TypeError, "Expected other #{other.class} to be of type #{self.class}" unless other.is_a?(self.class)

          result = []
          remaining_content = Array.new(self) # TODO: I want a copy of the array, not a deep clone
          other_enum = other.each_with_index

          loop do
            if items_are_equal?(other_enum.peek[0], remaining_content[0])
              other_enum.next
              remaining_content.shift
            elsif items_are_changed?(other, other_enum, remaining_content)
              result.concat(compute_item_changes(other, other_enum, self, remaining_content[0]))
              remaining_content.shift
              other_enum.next
            elsif !remaining_content.empty? && !other.smart_include?(remaining_content[0])
              result << Diff::Delete.new(Diff::ArchimateNodeReference.for_node(self, smart_find(remaining_content[0])))
              remaining_content.shift
            elsif !smart_include?(other_enum.peek[0])
              result << Diff::Insert.new(Diff::ArchimateNodeReference.for_node(other, other_enum.next[1]))
            elsif smart_include?(other_enum.peek[0])
              result << Diff::Move.new(
                Diff::ArchimateNodeReference.for_node(other, other_enum.peek[1]),
                Diff::ArchimateNodeReference.for_node(self, smart_find(other_enum.peek[0]))
              )
              remaining_item = remaining_content.smart_find(other_enum.peek[0])
              result.concat(compute_item_changes(other, other_enum, self, remaining_content[remaining_item]))
              remaining_content.delete(remaining_item, remaining_content[remaining_item]) if remaining_content.smart_include?(other_enum.peek[0])
              other_enum.next
            else
              raise "Unhandled diff case for remaining_content: #{remaining_content[0]} and #{other_enum.peek[0]}"
            end
          end

          result.concat(
            remaining_content
              .reject { |item| other.include?(item) }
              .map do |item|
                Diff::Delete.new(Diff::ArchimateNodeReference.for_node(self, find_index(item)))
              end
          )
        end

        def patch(diffs)
          # TODO: Beware, order of diffs could break patching at the moment.
          Array(diffs).each do |diff|
            case diff
            when Diff::Delete
              delete(diff.target.array_index, diff.target.value)
            when Diff::Insert
              insert(diff.target.array_index, diff.target.value)
            when Diff::Change
              change(diff.target.array_index, diff.changed_from.value, diff.target.value)
            when Diff::Move
              move(diff.target.array_index, diff.target.value)
            else
              raise "Unexpected diff type: #{diff.class}"
            end
          end
          self
        end

        def items_are_equal?(a, b)
          a == b
        end

        def items_are_changed?(other, other_enum, remaining)
          !remaining.empty? &&
            case remaining[0]
            when DataModel::IdentifiedNode
              remaining[0].id == other_enum.peek[0].id
            when String, DataModel::ArchimateNode
              !other.include?(remaining[0]) && !include?(other_enum.peek[0])
            else
              raise "Unhandled type for #{remaining[0].class}"
            end
        end

        def compute_item_changes(other, other_enum, myself, my_item)
          case my_item
          when DataModel::ArchimateNode
            my_item.diff(other_enum.peek[0])
          else
            my_item.diff(other_enum.peek[0], self, other, other_enum.peek[1], find_index(my_item))
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

        def in_model=(model)
          @in_model = model
          each { |item| item.in_model = model }
        end

        def in_model
          @in_model if defined?(@in_model)
        end

        def parent=(par)
          @parent = par
          each { |i| i.parent = self }
        end

        def parent
          @parent if defined?(@parent)
        end

        def parent_attribute_name
          @parent_attribute_name if defined?(@parent_attribute_name)
        end

        def id
          object_id
        end

        def build_index(hash_index = {})
          hash_index[id] = self
          each_with_object(hash_index) do |i, a|
            i.primitive? ? a[i.object_id] = i : i.build_index(a)
          end
        end

        def match(other)
          self == other
        end

        def path(options = {})
          [
            parent&.path(options),
            parent_attribute_name
          ].compact.reject(&:empty?).join("/")
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
          ) unless value.is_a?(ArchimateNode) || value.is_a?(String) # && value =~ /^[0-9a-f]{8}$/)

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
          ) unless to_value.is_a?(ArchimateNode) || to_value.is_a?(String)
          self[smart_find(from_value)] = to_value
          self
        end

        def move(to_index, value)
          raise(ArgumentError, "to_index was blank") if to_index.nil?
          raise(ArgumentError, "Invalid to_index #{to_index.inspect} given for Array size #{size}") if to_index.negative? || to_index >= size
          raise(
            ArgumentError, "Invalid value type #{value.class}"
          ) unless value.is_a?(ArchimateNode) || value.is_a?(String)
          self.delete_at(smart_find(value))
          self.insert(to_index, value)
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
          "#{parent}/#{parent_attribute_name}"
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
