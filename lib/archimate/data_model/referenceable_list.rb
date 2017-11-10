# frozen_string_literal: true

require "forwardable"

module Archimate
  module DataModel
    # A list of things that can be referenced by another entity.
    class ReferenceableList
      extend Forwardable

      def_delegators :@list,
                     :[],
                     :all?,
                     :dig,
                     :each_with_object,
                     :find,
                     :hash,
                     :include?,
                     :map,
                     :none?,
                     :select,
                     :==,
                     :each,
                     :empty?,
                     :first,
                     :reduce,
                     :size

      attr_reader :parent

      def initialize(parent, contents = [], parent_attr_references = [])
        @parent = parent
        @parent_attr_references = parent_attr_references
        @list = contents || []
        add_references
      end

      def replace_with(contents)
        remove_references
        @list = contents
        add_references
      end

      def to_ary
        Array.new(@list).freeze
      end

      def push(item)
        return if @list.include?(item)
        add_item_references(item)
        @list << item
      end

      def inspect
        vals = @list.first(3).map(&:brief_inspect)
        "[#{vals.join(', ')}#{"...#{@list.size}" if @list.size > 3}]"
      end

      private

      def add_references
        @list.each { |item| add_item_references(item) }
      end

      def add_item_references(item)
        item.add_reference(parent)
        @parent_attr_references.each do |attr|
          item.add_reference(parent.send(attr)) if parent.send(attr)
        end
      end

      def remove_references
        @list.each do |item|
          item.remove_reference(parent)
          @parent_attr_references.each do |attr|
            item.remove_reference(parent.send(attr)) if parent.send(attr)
          end
        end
      end
    end
  end
end
