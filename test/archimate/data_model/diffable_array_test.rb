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

      def test_smart_find_for_identified_nodes
        subject = @model.elements
        @model.elements.each_with_index do |el, idx|
          assert_equal idx, subject.smart_find(el)
        end
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

        assert_equal([Diff::Delete.new(Diff::ArchimateArrayReference.new(base.elements, base.elements.index(deleted_element)))], result)

        merged = result[0].apply(merged)

        assert_equal local.to_h, merged.to_h
      end

      def test_diff_with_insert_and_apply
        base = build_model(with_elements: 3)
        inserted_element = build_element
        local = base.with(elements: base.elements + [inserted_element])

        diffs = base.diff(local)
        non_organization_diffs = diffs.reject { |diff| diff.target.path =~ /^organizations/ }

        assert_equal(
          [
            Diff::Insert.new(
              Diff::ArchimateArrayReference.new(
                local.elements,
                local.elements.find_index { |item| item.id == inserted_element.id }
              )
            )
          ],
          non_organization_diffs
        )

        merged = diffs.inject(base.clone) { |ary, diff| diff.apply(ary) }

        assert_equal local.to_h, merged.to_h
      end

      def test_diff_with_delete_of_diagram
        base = build_model(with_diagrams: 1)
        local = base.with(diagrams: [])

        diffs = base.diff(local)

        assert_equal 1, diffs.size
        assert_equal [Diff::Delete.new(Diff::ArchimateArrayReference.new(base.diagrams, 0))], diffs
      end

      def test_diff_change_of_non_identified_node
        base, local = build_model_with_bendpoints_diffs

        diffs = base.diff(local)

        assert_equal(
          [
            Diff::Change.new(
              Diff::ArchimateNodeAttributeReference.new(local.diagrams[0].children[0].source_connections[0].bendpoints[1], :start_x),
              Diff::ArchimateNodeAttributeReference.new(base.diagrams[0].children[0].source_connections[0].bendpoints[1], :start_x)
            )
          ], diffs
        )
      end

      def test_model_assignment
        assert_nil @subject.in_model
        @subject.in_model = @model
        assert_equal @model, @subject.in_model
      end

      def test_parent_assignment
        assert_nil @subject.parent
        @subject.parent = @model
        assert_equal @model, @subject.parent
      end

      def test_path
        assert_equal "elements", @model.elements.path
        assert_equal "elements/#{@model.elements.first.id}", @model.elements.first.path
        assert_equal "elements/#{@model.elements.last.id}", @model.elements.last.path
      end

      def test_attribute_name
        assert_equal 0, @model.elements[0].parent_attribute_name
        assert_equal 2, @model.elements[2].parent_attribute_name
      end

      def test_primitive
        refute @subject.primitive?
      end

      def xtest_delete
        element_to_delete = @model.elements[1]
        subject = @model.clone
        subject.elements.delete("1", subject.elements[1])

        assert_includes @model.elements, element_to_delete
        refute_includes subject.elements, element_to_delete
      end

      def xtest_insert # no longer a valid test
        subject = @model.clone
        element_to_insert = build_element

        subject.elements.insert(element_to_insert.id, element_to_insert)

        refute_includes @model.elements, element_to_insert
        assert_includes subject.elements, element_to_insert
        assert_equal 3, subject.elements.index(element_to_insert)
      end

      def xtest_change_with_identified_node
        subject = @model.clone
        element_to_change = @model.elements[1]
        changed_element = element_to_change.with(name: element_to_change.name + "-changed")

        subject.elements.change(1, element_to_change, changed_element)

        refute_includes @model.elements, changed_element
        assert_includes subject.elements, changed_element
        assert_equal 1, subject.elements.index(changed_element)
      end

      def test_independent_changes_element
        base = build_model(with_relationships: 2, with_diagrams: 1)
        base_el1 = base.elements.first
        base_el2 = base.elements.last
        local_el = base_el1.with(name: "#{base_el1.name}-local")
        remote_el = base_el2.with(name: "#{base_el2.name}-remote")
        local = base.with(elements: base.elements.map { |el| el.id == local_el.id ? local_el : el })
        remote = base.with(elements: base.elements.map { |el| el.id == remote_el.id ? remote_el : el })

        base_local = base.diff(local)

        assert_equal(
          [Diff::Change.new(
            Diff::ArchimateNodeAttributeReference.new(local.elements.first, :name),
            Diff::ArchimateNodeAttributeReference.new(base.elements.first, :name)
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
        array_diff_merge_test_case([], [], -> (base, local) { [] })
      end

      def test_same_array_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(a b c),
          -> (base, local) { [] }
        )
      end

      # a, b, c -> z, a, b, c
      def test_initial_insert_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(z a b c),
          -> (base, local) {
            [
              array_insert(local, 0)
            ]
          }
        )
      end

      # a, b, c -> b, c
      def test_initial_delete_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(b c),
          -> (base, local) {
            [
              array_delete(base, 0)
            ]
          }
        )
      end

      # a, b, c -> a, c
      def test_diff_with_internal_delete
        array_diff_merge_test_case(
          %w(a b c),
          %w(a c),
          -> (base, local) {
            [
              array_delete(base, 1)
            ]
          }
        )
      end

      # a, b, c -> a, c, b
      def test_reorder_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(a c b),
          -> (base, local) {
            [
              array_move(local, 1, base, 2)
            ]
          }
        )
      end

      def test_order_change_false_deletion_case
        array_diff_merge_test_case(
          %w(a b c),
          %w(a c b d),
          -> (base, local) {
            [
              array_move(local, 1, base, 2),
              array_insert(local, 3)
            ]
          }
        )
      end

      def test_order_change_false_deletion_case_with_elements
        added_element = build_element
        local = @model.with(
          elements: [
            @model.elements[0].dup,
            @model.elements[2].dup,
            @model.elements[1].dup,
            added_element
          ]
        )

        diffs = @model.diff(local)
        non_organization_diffs = diffs.reject { |diff| diff.target.path =~ /^organizations/ }

        assert_equal(
          [
            Diff::Move.new(
              Diff::ArchimateArrayReference.new(local.elements, 1),
              Diff::ArchimateArrayReference.new(@model.elements, 2)
            ),
            Diff::Insert.new(
              Diff::ArchimateArrayReference.new(local.elements, 3)
            )
          ],
          non_organization_diffs
        )
      end

      # a, b, c -> a, b', c
      def test_changed_value
        array_diff_merge_test_case(
          %w(a b c),
          %w(a bp c),
          -> (base, local) {
            [
              array_change(local, 1, base, 1)
            ]
          }
        )
      end

      # a, b, c -> z, c, b'
      def test_changed_value_and_move_with_change
        array_diff_merge_test_case(
          %w(a b c),
          %w(z c bp),
          -> (base, local) {
            [
              array_change(local, 0, base, 0),
              array_delete(base, 1),
              array_insert(local, 2)
            ]
          }
        )
      end

      # a, b, c -> a, b, c, d
      def test_insert_at_end_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(a b c d),
          -> (base, local) {
            [
              array_insert(local, 3)
            ]
          }
        )
      end

      # a, b, c -> a, b
      def test_delete_at_end_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(a b),
          -> (base, local) {
            [
              array_delete(base, 2)
            ]
          }
        )
      end

      # a, b, c -> a, z, c
      def test_changed_value_duplicate_case
        array_diff_merge_test_case(
          %w(a b c),
          %w(a z c),
          -> (base, local) {
            [
              array_change(local, 1, base, 1)
            ]
          }
        )
      end

      # a, b, c -> a, z, b, c
      def test_insert_in_middle_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(a z b c),
          -> (base, local) {
            [
              array_insert(local, 1)
            ]
          }
        )
      end

      # a, b, c -> a, z, b', c
      def test_insert_with_change_in_middle_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(a z bp c),
          -> (base, local) {
            [
              array_change(local, 1, base, 1),
              array_insert(local, 2)
            ]
          }
        )
      end

      def test_diff_with_delete_and_ending_insert
        array_diff_merge_test_case(
          %w(a b c),
          %w(a c d),
          -> (base, local) {
            [
              array_delete(base, 1),
              array_insert(local, 2)
            ]
          }
        )
      end

      # a, b, c -> c, x, b, y, z, a
      def test_reverse_order_with_inserts_diff
        array_diff_merge_test_case(
          %w(a b c),
          %w(c x b y z a),
          -> (base, local) {
            [
              array_move(local, 0, base, 2),
              array_insert(local, 1),
              array_move(local, 2, base, 1),
              array_insert(local, 3),
              array_insert(local, 4)
            ]
          }
        )
      end

      def test_find_index_of_previous_item_in_array
        base = %w(a b d)
        ary = %w(a b c d)
        assert_equal(1, base.previous_item_index(ary, "d"))
        assert_equal(-1, base.previous_item_index(ary, "a"))
        assert_equal(0, base.previous_item_index(ary, "b"))
        assert_equal(-1, base.previous_item_index(ary, "c"))
        assert_equal(-1, base.previous_item_index(ary, "z"))
      end

      def test_previous_item_index
        base = build_model(
          organizations: [
            build_organization(
              items: %w(m n o a b x y z c)
            )
          ]
        )
        local = base.with(
          organizations: [
            base.organizations[0].with(
              items: %w(a c b d)
            )
          ]
        )

        base_items = base.organizations[0].items
        local_items = local.organizations[0].items

        assert_equal(-1, base_items.previous_item_index(local_items, local_items[0]))
        assert_equal(4, base_items.previous_item_index(local_items, local_items[1]))
        assert_equal(3, base_items.previous_item_index(local_items, local_items[2]))
        assert_equal(-1, base_items.previous_item_index(local_items, local_items[3]))
      end

      def test_previous_item_index_for_reverse_case
        base = build_model(
          organizations: [
            build_organization(
              items: %w(a b c)
            )
          ]
        )
        local = base.with(
          organizations: [
            base.organizations[0].with(
              items: %w(c b a)
            )
          ]
        )

        merged = base.clone
        merged_items = merged.organizations[0].items
        local_items = local.organizations[0].items

        assert_equal(1, merged_items.previous_item_index(local_items, local_items[0]))
        assert_equal(0, merged_items.previous_item_index(local_items, local_items[1]))
        assert_equal(-1, merged_items.previous_item_index(local_items, local_items[2]))
      end

      private

      def array_diff_merge_test_case(base_ary, local_ary, expected)
        base = build_model(organizations: [build_organization(items: base_ary)])
        local = base.with(organizations: [base.organizations[0].with(items: local_ary)])

        diffs = base.diff(local)

        merged = diffs.inject(base.clone) { |ary, diff| diff.apply(ary) }

        assert_equal expected.call(base, local), diffs
        assert_equal local, merged

        merged_ary = base.organizations[0].items.clone.patch(diffs)

        assert_equal local.organizations[0].items, merged_ary
      end

      def array_change(local, local_idx, base, base_idx)
        Diff::Change.new(
          Diff::ArchimateArrayReference.new(local.organizations[0].items, local_idx),
          Diff::ArchimateArrayReference.new(base.organizations[0].items, base_idx)
        )
      end

      def array_move(local, local_idx, base, base_idx)
        Diff::Move.new(
          Diff::ArchimateArrayReference.new(local.organizations[0].items, local_idx),
          Diff::ArchimateArrayReference.new(base.organizations[0].items, base_idx)
        )
      end

      def array_delete(base, base_idx)
        Diff::Delete.new(Diff::ArchimateArrayReference.new(base.organizations[0].items, base_idx))
      end

      def array_insert(local, local_idx)
        Diff::Insert.new(Diff::ArchimateArrayReference.new(local.organizations[0].items, local_idx))
      end

      def validate_model_refs(node, model)
        return if node.primitive?
        raise "Invalid in_model value: '#{node.in_model}' parent: '#{node.parent}' for #{node.class} at path #{node.path}" if node.in_model.nil? && !node.is_a?(Archimate::DataModel::Model)
        case node
        when DataModel::ArchimateNode
          node.struct_instance_variables.each do |attr|
            validate_model_refs(node[attr], model)
          end
        when Array
          node.each_with_index do |val, idx|
            validate_model_refs(val, model)
          end
        end
      end
    end
  end
end
