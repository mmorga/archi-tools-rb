# frozen_string_literal: true
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

      def test_diff_on_empty
        assert_empty [].diff([])
      end

      def test_diff_with_all_same
        assert_empty @subject.diff(@subject)
      end

      def test_diff_with_insert
        other = @subject + ["peach"]
        result = @subject.diff(other)
        node_ref = Archimate.node_reference(other, other.find_index("peach"))

        assert_kind_of Diff::ArchimateArrayPrimitiveReference, node_ref
        assert_equal(
          [Diff::Insert.new(node_ref)],
          result
        )
        assert_equal(
          "peach",
          result[0].target.value
        )
      end

      def test_diff_with_delete_primitive
        other = @subject - ["orange"]
        result = @subject.diff(other)

        assert_equal(
          [Diff::Delete.new(Archimate.node_reference(@subject, 1))],
          result
        )
      end

      def test_diff_with_delete_and_apply
        base = build_model(with_elements: 3)
        merged = base.clone
        deleted_element = base.elements[1]
        local = base.with(elements: base.elements - [deleted_element])

        result = base.diff(local)

        assert_equal([Diff::Delete.new(Archimate.node_reference(deleted_element))], result)
        assert_equal deleted_element.parent, result[0].target.parent

        merged = result[0].apply(merged)

        assert_equal local, merged
      end

      def test_diff_with_insert_and_apply
        base = build_model(with_elements: 3)
        inserted_element = build_element
        local = base.with(elements: base.elements + [inserted_element])

        result = base.diff(local)

        assert_equal([Diff::Insert.new(Archimate.node_reference(inserted_element))], result)

        merged = result[0].apply(base.clone)

        assert_equal local, merged
      end

      def test_diff_with_primitive_change
        other = @subject + ["peach"] - ["orange"]
        result = @subject.diff(other)

        assert_equal(
          [Diff::Delete.new(Archimate.node_reference(@subject, 1)),
           Diff::Insert.new(Archimate.node_reference(other, 2))],
          result
        )
      end

      def test_diff_with_delete_of_diagram
        base = build_model(with_diagrams: 1)
        local = base.with(diagrams: [])

        diffs = base.diff(local)

        assert_equal 1, diffs.size
        assert_equal [Diff::Delete.new(Archimate.node_reference(base.diagrams.first))], diffs
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

      def xtest_diff_change_of_primitive
        fail "write me"
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

      def test_match
        assert @subject.match(@subject)
        refute @subject.match([])
        refute @subject.match(%w(chevy ford toyota))
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
            Diff::Change.new(
              Archimate.node_reference(local.elements, 2),
              Archimate.node_reference(@model.elements, 1)
            ),
            Diff::Insert.new(
              Archimate.node_reference(local.elements, 3)
            )
          ],
          @model.diff(local)
        )
      end

      def test_order_change_false_deletion_case_with_primitives
        local = [
          @subject[0],
          @subject[2],
          @subject[1]
        ]

        result = @subject.diff(local)

        assert_equal(
          [
            Diff::Change.new(
              Archimate.node_reference(local, 2),
              Archimate.node_reference(@subject, 1)
            )
          ],
          result
        )
      end
    end
  end
end
