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

      def initialize(parent, contents = [])
        @parent = parent
        @list = contents || []
        @list.each { |item| item.add_reference(parent) }
      end

      def replace_with(contents)
        @list.each { |item| item.remove_reference(parent) }
        @list = contents
        @list.each { |item| item.add_reference(parent) }
      end

      def to_ary
        Array.new(@list).freeze
      end

      def push(item)
        return if @list.include?(item)
        item.add_reference(parent)
        @list << item
      end
    end
  end
end
