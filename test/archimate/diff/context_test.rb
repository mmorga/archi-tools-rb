# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ContextTest < Minitest::Test
      def test_new
        model1 = build(:model)
        model2 = build(:model)
        ctx = Context.new(model1, model2)
        assert_equal model1, ctx.model1
        assert_equal model2, ctx.model2
      end

        # context.in(:model, @model1.id) do |c|
        #   c.in(:id, StringDiff.new)
        #   c.in(:name, StringDiff.new)
        #   c.in(:documentation, UnorderedListDiff.new)
        #   c.in(:properties, UnorderedListDiff.new)
        #   c.in(:elements, IdHashDiff.new(ElementDiff))

      # def test_delete_with_entity
      #   d = Difference.delete("from_val", :model)
      #   assert_equal :model, d.entity
      #   assert_equal "from_val", d.from
      # end

      # def test_insert
      #   d = Difference.insert("to_val", :model)
      #   assert_equal :model, d.entity
      #   assert_equal "to_val", d.to
      # end

      # def test_context
      #   d = Difference.context(:model, "123")
      #   assert_equal :model, d.entity
      #   assert_equal "123", d.parent
      # end

      # def test_apply
      #   context = Difference.context(:model, "123")
      #   diffs = [
      #     Difference.delete("I'm deleted"),
      #     Difference.insert("I'm inserted")
      #   ]
      #   context.apply(diffs).each do |d|
      #     assert_equal :model, d.entity
      #     assert_equal "123", d.parent
      #   end
      # end
    end
  end
end
