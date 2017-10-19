# frozen_string_literal: true
module Archimate
  module DataModel
    module DiffableArray
      using DiffablePrimitive

      refine Array do
        using DiffablePrimitive

        attr_writer :parent_attribute_name

        def in_model
          @in_model if defined?(@in_model)
        end

        def parent
          @parent if defined?(@parent)
        end

        def id
          object_id.to_s
        end

        def ancestors
          result = [self]
          p = self
          result << p until (p = p.parent).nil?
          result
        end

        def primitive?
          false
        end

        # def diff(other)
        #   raise TypeError, "Expected other #{other.class} to be of type #{self.class}" unless other.is_a?(self.class)
        #   raise "Well Hell other #{other.path} in_model is nil" if other.in_model.nil?
        #   raise "Well Hell my path `#{path}` in_model is nil" if in_model.nil?

        #   result = []
        #   remaining_content = Array.new(self) # TODO: I want a copy of the array, not a deep clone
        #   other_enum = other.each_with_index

        #   loop do
        #     if other_enum.peek[0] == remaining_content[0]
        #       other_enum.next
        #       remaining_content.shift
        #     elsif items_are_changed?(other, other_enum, remaining_content)
        #       result.concat(compute_item_changes(other, other_enum, self, remaining_content[0]))
        #       remaining_content.shift
        #       other_enum.next
        #     elsif !remaining_content.empty? && !other.smart_include?(remaining_content[0])
        #       result << Diff::Delete.new(Diff::ArchimateArrayReference.new(self, smart_find(remaining_content[0])))
        #       remaining_content.shift
        #     elsif !smart_include?(other_enum.peek[0])
        #       result << Diff::Insert.new(Diff::ArchimateArrayReference.new(other, other_enum.next[1]))
        #     elsif smart_include?(other_enum.peek[0])
        #       result << Diff::Move.new(
        #         Diff::ArchimateArrayReference.new(other, other_enum.peek[1]),
        #         Diff::ArchimateArrayReference.new(self, smart_find(other_enum.peek[0]))
        #       )
        #       remaining_item_idx = remaining_content.smart_find(other_enum.peek[0])
        #       if remaining_item_idx
        #         result.concat(compute_item_changes(other, other_enum, self, remaining_content[remaining_item_idx]))
        #         remaining_content.delete_at(remaining_item_idx) if remaining_content.smart_include?(other_enum.peek[0])
        #       end
        #       other_enum.next
        #     else
        #       raise "Unhandled diff case for remaining_content: #{remaining_content[0]} and #{other_enum.peek[0]}"
        #     end
        #   end

        #   result.concat(
        #     remaining_content
        #       .reject { |item| other.include?(item) }
        #       .map do |item|
        #         Diff::Delete.new(Diff::ArchimateArrayReference.new(self, find_index(item)))
        #       end
        #   )
        # end

        # TODO: This may not continue to live here. Only used by testing.
        # def patch(diffs)
        #   # TODO: Beware, order of diffs could break patching at the moment.
        #   Array(diffs).each do |diff|
        #     case diff
        #     when Diff::Delete
        #       delete_at(smart_find(diff.target.value))
        #     when Diff::Insert
        #       insert(diff.target.array_index, diff.target.value)
        #     when Diff::Change
        #       self[smart_find(diff.changed_from.value)] = diff.target.value
        #     when Diff::Move
        #       insert(diff.target.array_index, delete_at(smart_find(diff.target.value)))
        #     else
        #       raise "Unexpected diff type: #{diff.class}"
        #     end
        #   end
        #   self
        # end

        def items_are_changed?(other, other_enum, remaining)
          !remaining.empty? &&
            case remaining[0]
            when DataModel::Referenceable
              remaining[0].id == other_enum.peek[0].id
            when String, DataModel::ArchimateNode
              !other.include?(remaining[0]) && !include?(other_enum.peek[0])
            else
              raise "Unhandled type for #{remaining[0].class}"
            end
        end

        def compute_item_changes(other, other_enum, _myself, my_item)
          case my_item
          when DataModel::ArchimateNode
            my_item.diff(other_enum.peek[0])
          else
            my_item.diff(other_enum.peek[0], self, other, other_enum.peek[1], find_index(my_item))
          end
        end

        def in_model=(model)
          puts "#{self.inspect} is frozen" if self.frozen?
          @in_model = model
          each { |item| item.in_model = model }
        end

        def parent=(par)
          @parent = par
          each { |i| i.parent = self }
        end

        def parent_attribute_name
          @parent_attribute_name if defined?(@parent_attribute_name)
        end

        def build_index(hash_index = {})
          reduce(hash_index) { |hi, array_item| array_item.build_index(hi) }
        end

        def path(options = {})
          [
            parent&.path(options),
            parent_attribute_name
          ].compact.reject(&:empty?).join("/")
        end

        def clone
          map(&:clone)
        end

        def dup
          map(&:dup)
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
          when Referenceable
            lazy.map(&:id).find_index(val.id)
          else
            find_index(val)
          end
        end

        def smart_include?(val)
          case val
          when Referenceable
            lazy.map(&:id).include?(val.id)
          else
            include?(val)
          end
        end

        def smart_intersection(ary)
          select { |item| ary.smart_include?(item) }
        end

        def after(idx)
          return [] if idx >= size - 1
          self[idx + 1..-1]
        end

        # Given a node in self and ary,
        # return the idx of first node p in self that exists in both self and ary
        # and is previous to node in self
        def previous_item_index(ary, node)
          return -1 unless ary.smart_include?(node)
          initial_idx = smart_find(node)
          return -1 if initial_idx.nil?

          (initial_idx - 1).downto(0).find(-> { -1 }) do |idx|
            ary.smart_include?(at(idx))
          end
        end
      end
    end
  end
end
