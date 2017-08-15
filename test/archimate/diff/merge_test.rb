# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    # Ok - here's the plan
    # Produce two sets of Differences on two models
    # Use cases:
    # 1. [x] Inserts (always good)
    # 2. [x] change on the same path == conflict to be resolved
    # 3. [x] change on diff paths == ok
    # 4. [x] delete: diagram (ok) unless other changed that diagram - then conflict
    # 5. [x] delete: relationship (ok - if source & target also deleted & not referenced by remaining diagrams)
    # 6. [x] delete: element (ok - if not referenced by remaining diagram updated by other)
    # 7. [ ] merged: duplicate elements where merged into one
    #
    # Need to also consider - want to guarantee that final merge is in good state.
    # What if local or remote (or base for that matter) isn't?
    class MergeTest < Minitest::Test
      attr_reader :base
      attr_reader :base_el1
      attr_reader :base_el2
      attr_reader :base_rel1
      attr_reader :base_rel2

      def setup
        skip("Diff re-write")
        @base = build_model(with_relationships: 2, with_diagrams: 1)
        @base_el1 = base.elements.first
        @base_el2 = base.elements.last
        @base_rel1 = base.relationships.first
        @base_rel2 = base.relationships.last
        @subject = Merge.new
      end

      def test_independent_changes_element
        skip("Diff re-write")
        local_el = base_el1.with(name: "#{base_el1.name}-local")
        remote_el = base_el2.with(name: "#{base_el2.name}-remote")
        local = base.with(elements: base.elements.map { |el| el.id == local_el.id ? local_el : el })
        remote = base.with(elements: base.elements.map { |el| el.id == remote_el.id ? remote_el : el })

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        puts "Remote El Id is #{remote_el.id}"
        puts "Remote:"
        puts remote.elements.map(&:inspect).join("\n")
        puts "Merged:"
        puts merged.elements.map(&:inspect).join("\n")

        (0..remote.elements.size - 1).each {|i|
          assert_equal remote.elements[i].id, merged.elements[i].id
        }
        assert_includes merged.elements, remote.elements.find_by_id(remote_el.id)
        assert_includes merged.elements, local.elements.find_by_id(local_el.id)
        refute_equal base, merged
      end

      def test_independent_changes_element_documentation
        skip("Diff re-write")
        assert_empty base_el1.documentation
        local_el = base_el1.with(documentation: build_documentation)
        remote_el = base_el2.with(documentation: build_documentation)
        local = base.with(elements: base.elements.map { |el| el.id == local_el.id ? local_el : el })
        remote = base.with(elements: base.elements.map { |el| el.id == remote_el.id ? remote_el : el })

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        refute_empty merged.elements.find_by_id(local_el.id).documentation
        refute_empty merged.elements.find_by_id(remote_el.id).documentation
        refute_equal base, merged
      end

      def test_both_insert_element_documentation
        skip("Diff re-write")
        doc1 = build_documentation
        doc2 = build_documentation
        local_el = base_el1.with(documentation: doc1)
        remote_el = base_el1.with(documentation: doc2)
        local = base.with(elements: base.elements.map { |el| el.id == local_el.id ? local_el : el })
        remote = base.with(elements: base.elements.map { |el| el.id == remote_el.id ? remote_el : el })

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts.conflicts
        assert_includes merged.elements.find { |i| i.id == base_el1.id }.documentation, doc1[0]
        assert_includes merged.elements.find { |i| i.id == base_el1.id }.documentation, doc2[0]
        refute_equal base, merged
      end

      def test_independent_changes_relationship
        skip("Diff re-write")
        local_rel = base.relationships.first.with(name: "#{base.relationships.first.name}-local")
        remote_rel = base.relationships.last.with(name: "#{base.relationships.last.name}-remote")
        assert base.relationships.size > 1
        local = base.with(relationships: base.relationships.map { |rel| rel.id == local_rel.id ? local_rel : rel })
        remote = base.with(relationships: base.relationships.map { |rel| rel.id == remote_rel.id ? remote_rel : rel })

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        assert_equal merged.relationships.find_by_id(local_rel.id).name, local_rel.name
        assert_equal merged.relationships.find_by_id(remote_rel.id).name, remote_rel.name
        refute_equal base, merged
      end

      def test_conflict
        skip("Diff re-write")
        local_el = base_el1.with(name: "#{base_el1.name}-local")
        remote_el = base_el1.with(name: "#{base_el1.name}-remote")
        base_elements = base.elements.reject { |i| i == base_el1 }
        local = base.with(elements: Array(local_el) + base_elements)
        remote = base.with(elements: Array(remote_el) + base_elements)

        merged, conflicts = @subject.three_way(base, local, remote)

        expected = Conflict.new(
          Change.new(
            ArchimateNodeAttributeReference.new(local.elements[0].name, :text),
            ArchimateNodeAttributeReference.new(base_el1.name, :text)
          ),
          Change.new(
            ArchimateNodeAttributeReference.new(remote.elements[0].name, :text),
            ArchimateNodeAttributeReference.new(base_el1.name, :text)
          ),
          "Checking for Differences in one change set that conflict with changes in other change set at the same path"
        )
        assert_equal expected, conflicts.first
        assert_equal base, merged
      end

      def test_local_remote_duplicate_change_no_conflict
        skip("Diff re-write")
        local = base.with(
          elements:
            base.elements.map { |el| el.id == base_el1.id ? base_el1.with(name: "#{base_el1.name}-same") : el }
        )
        remote = local.clone

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        assert_equal local.elements.find_by_id(base_el1.id), merged.elements.find_by_id(base_el1.id)
        assert_equal local, merged
        assert_equal remote, merged
      end

      def test_insert_in_remote
        skip("Diff re-write")
        local = base
        iel = build_element
        remote = base.with(elements: base.elements + [iel])

        merged, _conflicts = @subject.three_way(base, local, remote)

        assert_equal remote.to_h, merged.to_h
        refute_equal base, merged
      end

      def test_insert_in_local
        skip("Diff re-write")
        iel = build_element
        local = base.with(elements: base.elements + [iel])

        merged, conflicts = @subject.three_way(base, local, base.clone)

        assert_empty conflicts
        assert_equal local.to_h, merged.to_h
      end

      def test_insert_in_local_and_remote
        skip("Diff re-write")
        ier = build_element
        remote = base.with(elements: base.elements + [ier])
        iel = build_element
        local = base.with(elements: base.elements + [iel])
        refute_includes base.elements, ier.id
        refute_includes base.elements, iel.id

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        assert_equal ier, merged.elements.find { |i| i.id == ier.id }
        assert_equal iel, merged.elements.find { |i| i.id == iel.id }
      end

      def test_apply_diff_insert_element
        skip("Diff re-write")
        base = build_model(with_elements: 3)
        local = base.with(elements: base.elements + [build_element])
        remote = base.clone

        merged, _conflicts = @subject.three_way(base, local, remote)

        assert_equal local.to_h, merged.to_h
        refute_equal base, merged
      end

      def test_apply_diff_on_model_attributes
        skip("Diff re-write")
        m1 = build_model
        m2 = m1.with(id: Faker::Number.hexadecimal(8))

        merged, conflicts = @subject.three_way(m1, m2, m1.clone)

        assert_empty conflicts
        assert_equal m2, merged
      end

      def test_no_changes
        skip("Diff re-write")
        local = Archimate::DataModel::Model.new(base.to_h)
        remote = Archimate::DataModel::Model.new(base.to_h)

        merged, _conflicts = @subject.three_way(base, local, remote)

        assert_equal base, merged
        assert_equal local, merged
        assert_equal remote, merged
      end

      # Given a local where a diagram has been updated and
      # a remote where the same diagram has been deleted
      # expect that the conflicts set includes the two differences
      def test_find_diagram_delete_update_conflicts
        skip("Diff re-write")
        local = base.with(
          diagrams:
            base.diagrams.map do |diagram|
              if diagram == base.diagrams.first
                diagram.with(
                  nodes:
                    diagram.nodes.map do |view_node|
                      if view_node == diagram.nodes.first
                        view_node.with(name: view_node.name.to_s + "-modified")
                      else
                        view_node
                      end
                    end
                )
              else
                diagram
              end
            end
        )

        remote = base.with(diagrams: base.diagrams.reject { |diagram| diagram == base.diagrams.first })

        merged, conflicts = @subject.three_way(base, local, remote)

        refute_empty conflicts
        assert_equal base, merged
      end

      # delete: element (ok - if not referenced by other diagrams that was updated)
      # TODO: this sort of implies that the diagram changes are already applied
      def test_delete_element_when_still_referenced_in_remaining_diagrams
        skip("Diff re-write")
        diagram = base.diagrams.first
        view_node = diagram.nodes.first

        # update diagram that references view_node
        remote = base.with(
          diagrams: base.diagrams + [
            build_diagram(
              nodes:
                [build_view_node(element: view_node.element)]
            )
          ]
        )

        # delete element from local
        local = base.with(
          elements: base.elements.reject { |e| e.id == view_node.element.id }
        )

        merged, conflicts = @subject.three_way(base, local, remote)

        refute_empty conflicts.map(&:to_s)
        assert_equal base.to_h, merged.to_h
      end

      # delete: element (ok - unless other doc doesn't add relationship which references it)
      # TODO: determine if this is a valid test case
      def test_delete_element_when_referenced_in_other_change_set
        skip("Diff re-write")
        target_relationship = base.relationships.first
        element_id = target_relationship.source
        relationship_id = target_relationship.id
        new_relationship = build_relationship(source_id: element_id)
        remote = base.with(
          relationships: base.relationships.merge(new_relationship.id => new_relationship)
        )

        local = base.with(
          elements: base.elements.reject { |k, _v| k == element_id },
          relationships: base.relationships.reject { |k, _v| k == relationship_id }
        )

        merged, conflicts = @subject.three_way(base, local, remote)

        refute conflicts.empty?
        assert_equal base, merged
      end

      def test_handle_bounds_changes
        skip("Diff re-write")
        diagram = base.diagrams.first.clone
        bounds = diagram.nodes[0].bounds
        diagram.nodes[0] = diagram.nodes[0].with(bounds: bounds.with(x: bounds.x + 10.0, y: bounds.y + 10.0))
        updated_diagrams = base.diagrams.reject { |d| d.id == diagram.id }.unshift(diagram)
        local = base.with(diagrams: updated_diagrams)

        merged, conflicts = @subject.three_way(base, local, base.clone)

        assert_empty conflicts
        refute_equal base, merged
        assert_equal local, merged
      end

      def test_merge_order_of_elements
        skip("Diff re-write")
        local_elements = build_element_list(with_elements: 2)
        remote_elements = build_element_list(with_elements: 2)
        base = build_model(with_elements: 3)
        local = base.with(elements: base.elements + local_elements)
        remote = base.with(elements: base.elements + remote_elements)
        expected_elements = base.elements + remote_elements + local_elements

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        assert_equal expected_elements, merged.elements
      end

      def test_merge_with_internal_insert_of_elements_on_local
        skip("Diff re-write")
        head_elements = build_element_list(with_elements: 2)
        tail_elements = build_element_list(with_elements: 2)
        local_elements = build_element_list(with_elements: 2)
        base = build_model(elements: head_elements + tail_elements)
        local = base.with(elements: head_elements + local_elements + tail_elements)
        remote = base.clone
        expected_elements = head_elements + local_elements + tail_elements

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        assert_equal expected_elements, merged.elements
      end

      # This test tests the case when an item is moved to a sub-organization and
      # the sub-organization is deleted.
      def test_merge_with_element_moving_organizations
        skip("Diff re-write")
        el_list_1 = build_element_list(with_elements: 3)
        el_list_2 = build_element_list(with_elements: 3)
        moving_element = build_element
        base = build_model(
          elements: el_list_1 + [moving_element] + el_list_2,
          organizations: [
            build_organization(
              name: "top level organization",
              items: (el_list_1 + el_list_2).map(&:id),
              organizations: [
                build_organization(
                  name: "sub organization",
                  items: [moving_element.id],
                  organizations: []
                )
              ]
            )
          ]
        )

        local = base.clone
        remote = base.with(
          organizations: [
            base.organizations[0].with(
              items: base.organizations[0].items + [moving_element.id],
              organizations: []
            )
          ]
        )

        merged, conflicts = @subject.three_way(base, local, remote)

        assert_empty conflicts
        assert_equal remote.organizations.size, merged.organizations.size
        assert_empty merged.organizations[0].organizations
        assert_includes merged.organizations[0].items, moving_element.id
        assert_equal remote, merged
      end
    end
  end
end
