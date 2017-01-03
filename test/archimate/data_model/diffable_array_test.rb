#243 frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DiffableArrayTest < Minitest::Test
      using DiffableArray
      using DiffablePrimitive

      def setup
        @model = build_model(with_elements: 3)
        @subject = %w(apple orange banana)
      end

      def test_diff_on_non_array_error_state
        assert_raises(TypeError) { @subject.diff(42) }
      end

      def test_diff_with_delete_and_apply
        base = build_model(with_elements: 3)
        merged = base.clone
        deleted_element = base.elements[1]
        local = base.with(elements: base.elements - [deleted_element])

        result = base.diff(local)

        assert_equal([Diff::Delete.new(Archimate.node_reference(base.elements, base.elements.index(deleted_element)))], result)
        # assert_equal deleted_element.parent, result[0].target.parent

        merged = result[0].apply(merged)

        assert_equal local.to_h, merged.to_h
      end

      def test_diff_with_insert_and_apply
        base = build_model(with_elements: 3)
        inserted_element = build_element
        local = base.with(elements: base.elements + [inserted_element])

        result = base.diff(local)

        assert_equal(
          [
            Diff::Insert.new(
              Archimate.node_reference(
                local.elements,
                local.elements.find_index { |item| item.id == inserted_element.id }
              )
            )
          ],
          result
        )

        merged = result[0].apply(base.clone)

        assert_equal local, merged
      end

      def test_diff_with_delete_of_diagram
        base = build_model(with_diagrams: 1)
        local = base.with(diagrams: [])

        diffs = base.diff(local)

        assert_equal 1, diffs.size
        assert_equal [Diff::Delete.new(Archimate.node_reference(base.diagrams, 0))], diffs
      end

      def test_diff_change_of_non_identified_node
        base, local = build_model_with_bendpoints_diffs
        bendpoints = base.diagrams[0].children[0].source_connections[0].bendpoints
        changed_bendpoint = bendpoints[1].with(start_x: bendpoints[1].start_x + 10)

        diffs = base.diff(local)

        assert_equal(
          [
            Diff::Change.new(
              Archimate.node_reference(changed_bendpoint, "start_x"),
              Archimate.node_reference(bendpoints[1], "start_x")
            )
          ], diffs
        )
      end

      def test_assign_model
        assert_nil @subject.in_model
        @subject.assign_model(@model)
        assert_equal @model, @subject.in_model
      end

      def test_assign_parent
        assert_nil @subject.parent
        @subject.assign_parent(@model)
        assert_equal @model, @subject.parent
      end

      def test_path
        assert_equal "elements", @model.elements.path
        assert_equal "elements/#{@model.elements.first.id}", @model.elements.first.path
        assert_equal "elements/#{@model.elements.last.id}", @model.elements.last.path
      end

      def test_attribute_name
        assert_equal @model.elements[0].id, @model.elements.attribute_name(@model.elements[0])
        assert_equal @model.elements[2].id, @model.elements.attribute_name(@model.elements[2])
      end

      def test_primitive
        refute @subject.primitive?
      end

      def test_delete
        element_to_delete = @model.elements[1]
        subject = @model.clone
        subject.elements.delete("1", subject.elements[1])

        assert_includes @model.elements, element_to_delete
        refute_includes subject.elements, element_to_delete
      end

      def test_insert
        subject = @model.clone
        element_to_insert = build_element

        subject.elements.insert(element_to_insert.id, element_to_insert)

        refute_includes @model.elements, element_to_insert
        assert_includes subject.elements, element_to_insert
        assert_equal 3, subject.elements.index(element_to_insert)
      end

      def test_change_with_identified_node
        subject = @model.clone
        element_to_change = @model.elements[1]
        changed_element = element_to_change.with(label: element_to_change.label + "-changed")

        subject.elements.change(1, element_to_change, changed_element)

        refute_includes @model.elements, changed_element
        assert_includes subject.elements, changed_element
        assert_equal 1, subject.elements.index(changed_element)
      end

      def test_independent_changes_element
        base = build_model(with_relationships: 2, with_diagrams: 1)
        base_el1 = base.elements.first
        base_el2 = base.elements.last
        local_el = base_el1.with(label: "#{base_el1.label}-local")
        remote_el = base_el2.with(label: "#{base_el2.label}-remote")
        local = base.with(elements: base.elements.map { |el| el.id == local_el.id ? local_el : el })
        remote = base.with(elements: base.elements.map { |el| el.id == remote_el.id ? remote_el : el })

        base_local = base.diff(local)

        assert_equal(
          [Diff::Change.new(
            Archimate.node_reference(local.elements.first, "label"),
            Archimate.node_reference(base.elements.first, "label")
          )],
          base_local
        )
        assert_equal 1, base_local.size

        base_remote = base.diff(remote)
        assert_equal 1, base_remote.size
      end

      def test_referenced_identified_nodes
        subject = [
          build_source_connection(
            source: "a",
            target: "b",
            relationship: "c"
          )
        ]

        assert_equal %w(a b c), subject.referenced_identified_nodes.sort
      end

      def test_referenced_identified_nodes_on_primitive_array
        subject = %w(apple cherry banana)

        assert_empty subject.referenced_identified_nodes
      end

      def build_model_with_bendpoints_diffs
        base = build_model(
          diagrams: [
            build_diagram(
              children: [
                build_child(
                  source_connections: [
                    build_source_connection(
                      bendpoints: (1..3).map { build_bendpoint }
                    )
                  ]
                )
              ]
            )
          ]
        )
        bendpoints = base.diagrams[0].children[0].source_connections[0].bendpoints
        changed_bendpoint = bendpoints[1].with(start_x: bendpoints[1].start_x + 10)
        local = base.with(
          diagrams: [
            base.diagrams[0].with(
              children: [
                base.diagrams[0].children[0].with(
                  source_connections: [
                    base.diagrams[0].children[0].source_connections[0].with(
                      bendpoints: [
                        bendpoints[0],
                        changed_bendpoint,
                        bendpoints[2]
                      ]
                    )
                  ]
                )
              ]
            )
          ]
        )
        [base, local]
      end

      def test_empty_array_diff
        base = []
        local = []

        result = base.diff(local)
        # merged = result.inject(base.clone) { |ary, diff| diff.apply(ary) }
        merged = base.clone.patch(result)

        assert_empty result
        assert_equal local, merged
      end

      def test_same_array_diff
        base = %w(a b c)
        local = %w(a b c)

        result = base.diff(local)
        # merged = result.inject(base.clone) { |ary, diff| diff.apply(ary) }
        merged = base.clone.patch(result)

        assert_empty result
        assert_equal local, merged
      end

      # a, b, c -> z, a, b, c
      def test_initial_insert_diff
        base = %w(a b c)
        local = %w(z a b c)

        expected = [Diff::Insert.new(Archimate.node_reference(local, 0))]
        result = base.diff(local)
        # merged = result.inject(base.clone) { |ary, diff| diff.apply(ary) }
        merged = base.clone.patch(result)

        assert_equal expected, result
        assert_equal local, merged
      end

      # a, b, c -> b, c
      def test_initial_delete_diff
        base = %w(a b c)
        local = %w(b c)

        expected = [Diff::Delete.new(Archimate.node_reference(base, 0))]
        result = base.diff(local)
        # merged = result.inject(base.clone) { |ary, diff| diff.apply(ary) }
        merged = base.clone.patch(result)

        assert_equal expected, result
        assert_equal local, merged
      end

      # a, b, c -> a, c
      def test_diff_with_internal_delete
        base = %w(a b c)
        local = %w(a c)

        expected = [Diff::Delete.new(Archimate.node_reference(base, 1))]
        result = base.diff(local)
        # merged = result.inject(base.clone) { |ary, diff| diff.apply(ary) }
        merged = base.clone.patch(result)

        assert_equal expected, result
        assert_equal local, merged
      end

      # a, b, c -> a, c, b
      def test_reorder_diff
        base = %w(a b c)
        local = %w(a c b)

        assert_equal(
          [
            Diff::Move.new(
              Archimate.node_reference(local, 1),
              Archimate.node_reference(base, 2)
            )
          ],
          base.diff(local)
        )
      end

      def test_order_change_false_deletion_case
        base = %w(a b c)
        local = %w(a c b d)

        assert_equal(
          [
            Diff::Move.new(
              Archimate.node_reference(local, 1),
              Archimate.node_reference(base, 2)
            ),
            Diff::Insert.new(
              Archimate.node_reference(local, 3)
            )
          ],
          base.diff(local)
        )
      end

      def test_order_change_false_deletion_case
        added_element = build_element
        local = @model.with(
          elements: [
            @model.elements[0],
            @model.elements[2],
            @model.elements[1],
            added_element
          ]
        )

        assert_equal(
          [
            Diff::Move.new(
              Archimate.node_reference(local.elements, 1),
              Archimate.node_reference(@model.elements, 2)
            ),
            Diff::Insert.new(
              Archimate.node_reference(local.elements, 3)
            )
          ],
          @model.diff(local)
        )
      end

      # a, b, c -> a, b', c
      def test_changed_value
        base = %w(a b c)
        local = %w(a bp c)

        assert_equal(
          [
            Diff::Change.new(
              Archimate.node_reference(local, 1),
              Archimate.node_reference(base, 1)
            )
          ],
          base.diff(local)
        )
      end

      # a, b, c -> z, c, b'
      def test_changed_value_and_move_with_change
        base = %w(a b c)
        local = %w(z c bp)

        assert_equal(
          [
            Diff::Change.new(
              Archimate.node_reference(local, 0),
              Archimate.node_reference(base, 0)
            ),
            Diff::Delete.new(Archimate.node_reference(base, 1)),
            Diff::Insert.new(Archimate.node_reference(local, 2))
          ],
          base.diff(local)
        )
      end

      # a, b, c -> a, b, c, d
      def test_insert_at_end_diff
        base = %w(a b c)
        local = %w(a b c d)

        assert_equal(
          [Diff::Insert.new(Archimate.node_reference(local, 3))],
          base.diff(local)
        )
      end

      # a, b, c -> a, b
      def test_delete_at_end_diff
        base = %w(a b c)
        local = %w(a b)

        assert_equal(
          [Diff::Delete.new(Archimate.node_reference(base, 2))],
          base.diff(local)
        )
      end

      # a, b, c -> a, z, c
      def test_changed_value_duplicate_case
        base = %w(a b c)
        local = %w(a z c)

        assert_equal(
          [
            Diff::Change.new(
              Archimate.node_reference(local, 1),
              Archimate.node_reference(base, 1)
            )
          ],
          base.diff(local)
        )
      end

      # a, b, c -> a, z, b, c
      def test_insert_in_middle_diff
        base = %w(a b c)
        local = %w(a z b c)

        assert_equal(
          [Diff::Insert.new(Archimate.node_reference(local, 1))],
          base.diff(local)
        )
      end

      # a, b, c -> a, z, b', c
      def test_insert_with_change_in_middle_diff
        base = %w(a b c)
        local = %w(a z bp c)

        assert_equal(
          [
            Diff::Change.new(
              Archimate.node_reference(local, 1),
              Archimate.node_reference(base, 1)
            ),
            Diff::Insert.new(Archimate.node_reference(local, 2))
          ],
          base.diff(local)
        )
      end

      def test_diff_with_delete_and_ending_insert
        base = %w(a b c)
        local = %w(a c d)

        result = base.diff(local)

        assert_equal(
          [Diff::Delete.new(Archimate.node_reference(base, 1)),
           Diff::Insert.new(Archimate.node_reference(local, 2))],
          result
        )
      end

      # a, b, c -> c, x, b, y, z, a
      def xtest_reverse_order_with_inserts_diff
        base = %w(a b c)
        local = %w(c, x, b, y, z, a)

        assert_equal(
          [
            Diff::Change.new(
              Archimate.node_reference(local, 0),
              Archimate.node_reference(base, 2)
            ),
            Diff::Insert.new(Archimate.node_reference(local, 1)),
            Diff::Change.new(
              Archimate.node_reference(local, 2),
              Archimate.node_reference(base, 1)
            ),
            Diff::Insert.new(Archimate.node_reference(local, 3)),
            Diff::Insert.new(Archimate.node_reference(local, 4)),
            Diff::Change.new(
              Archimate.node_reference(local, 5),
              Archimate.node_reference(base, 0)
            )
          ],
          base.diff(local)
        )
      end
    end
  end
end
