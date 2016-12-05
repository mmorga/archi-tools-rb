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
          return [] if other.empty? || self == other
          inserted_or_changed = other - self
          []
            .concat(
              deleted_items(other)
                .map { |n| Diff::Delete.new(Archimate.node_reference(self, n)) }
            )
            .concat(
              inserted_or_changed
                .select { |r| none? { |l| l.match(r) } }
                .map { |n| Diff::Insert.new(Archimate.node_reference(other, n)) }
            )
            .concat(
              inserted_or_changed
                .select { |r| any? { |l| l.match(r) } }
                .map do |n|
                  Diff::Change.new(
                    Archimate.node_reference(other, n),
                    Archimate.node_reference(self, n)
                  )
                end
            )
        end

        def deleted_items(other)
          id_lookup = -> (x) { x.respond_to?(:id) ? x.id : x }
          deleted_ids = map(&id_lookup) - other.map(&id_lookup)
          deleted_ids.map { |id| at(index { |item| item.id == id }) }
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
      end
    end
  end
end
