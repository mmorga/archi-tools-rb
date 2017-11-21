# frozen_string_literal: true

module Archimate
  module DataModel
    # Something that can be referenced by another entity.
    module Referenceable
      def add_reference(referencer)
        references << referencer unless references.include?(referencer)
      end

      def remove_reference(referencer)
        references.delete(referencer)
      end

      def references
        @referenceable_set ||= []
      end

      def model
        references.find { |ref| ref.is_a?(Model) }
      end

      def destroy
        references.each { |ref| ref.remove_reference(self) }
        to_h.values.select { |v| v.is_a?(Referenceable) }.each { |ref| ref.remove_reference(self) }
      end

      def replace_with(other)
        references.dup.each do |ref|
          ref.replace_item_with(self, other)
          remove_reference(ref)
        end
      end

      def replace_item_with(item, replacement)
        # default not doing anything
        # puts Archimate::Color.uncolor("        Referenceable(#{cls_name(self)}).replace_item_with item: #{item} replacement: #{replacement}")
      end

      private

      def cls_name(o)
        o.class.name.split("::").last
      end

      def to_cls_name
        ->(o) { o.class.name.split("::").last }
      end
    end
  end
end
