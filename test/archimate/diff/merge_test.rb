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
    class MergeTest # < Minitest::Test
      attr_reader :aio
      attr_reader :base
      attr_reader :base_el1
      attr_reader :base_el2
      attr_reader :base_rel1
      attr_reader :base_rel2

      def setup
        @aio = Archimate::AIO.new(uout: StringIO.new, verbose: false, interactive: false)
        @base = build_model(with_relationships: 2, with_diagrams: 1)
        @base_el1 = base.elements.first
        @base_el2 = base.elements.last
        @base_rel1 = base.relationships.first
        @base_rel2 = base.relationships.last
      end

      def test_independent_changes_element
        local_el = base_el1.with(label: "#{base_el1.label}-local")
        remote_el = base_el2.with(label: "#{base_el2.label}-remote")
        local = base.insert_element(local_el)
        remote = base.insert_element(remote_el)

        merge = Merge.three_way(base, local, remote, aio)

        assert_empty merge.conflicts
        assert_includes merge.merged.elements, local_el
        assert_includes merge.merged.elements, remote_el
        refute_equal base, merge.merged
      end

      def test_independent_changes_element_documentation
        local_el = base_el1.with(documentation: build_documentation_list)
        remote_el = base_el2.with(documentation: build_documentation_list)
        local = base.insert_element(local_el)
        remote = base.insert_element(remote_el)

        merge = Merge.three_way(base, local, remote, aio)

        assert_empty merge.conflicts
        assert_includes merge.merged.elements, local_el
        assert_includes merge.merged.elements, remote_el
        refute_equal base, merge.merged
      end

      def test_both_insert_element_documentation
        doc1 = build_documentation_list
        doc2 = build_documentation_list
        local_el = base_el1.with(documentation: doc1)
        remote_el = base_el1.with(documentation: doc2)
        local = base.insert_element(local_el)
        remote = base.insert_element(remote_el)

        merge = Merge.three_way(base, local, remote, aio)

        assert_empty merge.conflicts
        assert_includes merge.merged.elements.find { |i| i.id == base_el1.id }.documentation, doc1[0]
        assert_includes merge.merged.elements.find { |i| i.id == base_el1.id }.documentation, doc2[0]
        refute_equal base, merge.merged
      end

      def test_independent_changes_relationship
        local_rel = base.relationships.first.with(name: "#{base.relationships.first.name}-local")
        remote_rel = base.relationships.last.with(name: "#{base.relationships.last.name}-remote")
        assert base.relationships.size > 1
        local = base.insert_relationship(local_rel)
        remote = base.insert_relationship(remote_rel)

        merge = Merge.three_way(base, local, remote, aio)

        assert_empty merge.conflicts
        assert_includes merge.merged.relationships, local_rel
        assert_includes merge.merged.relationships, remote_rel
        refute_equal base, merge.merged
      end

      def test_conflict
        local_el = base_el1.with(label: "#{base_el1.label}-local")
        remote_el = base_el1.with(label: "#{base_el1.label}-remote")
        base_elements = base.elements.reject { |i| i == base_el1 }
        local = base.with(elements: Array(local_el) + base_elements)
        remote = base.with(elements: Array(remote_el) + base_elements)

        merge = Merge.three_way(base, local, remote, aio)

        expected = Conflict.new(
          merge.base_local_diffs[0],
          merge.base_remote_diffs[0],
          "Differences in one change set conflict with changes in other change set at the same path"
        )
        assert_equal expected, merge.conflicts.first
        assert_equal base, merge.merged
      end

      def test_local_remote_duplicate_change_no_conflict
        local_el = base_el1.with(label: "#{base_el1.label}-same")
        remote_el = base_el1.with(label: "#{base_el1.label}-same")
        base_elements = base.elements.reject { |i| i == base_el1 }
        local = base.with(elements: Array(local_el) + base_elements)
        remote = base.with(elements: Array(remote_el) + base_elements)

        merge = Merge.three_way(base, local, remote, aio)

        assert_empty merge.conflicts
        assert_equal local_el, merge.merged.elements.first
        assert_equal remote_el, merge.merged.elements.first
      end

      def test_insert_in_remote
        local = base
        iel = build_element
        remote = base.insert_element(iel)

        merge = Merge.three_way(base, local, remote, aio)

        assert_equal remote, merge.merged
        refute_equal base, merge.merged
      end

      def test_insert_in_local
        remote = base
        iel = build_element
        local = base.insert_element(iel)

        merge = Merge.three_way(base, local, remote, aio)

        assert_equal local, merge.merged
      end

      def test_insert_in_local_and_remote
        ier = build_element
        remote = base.insert_element(ier)
        iel = build_element
        local = base.insert_element(iel)
        refute_includes base.elements, ier.id
        refute_includes base.elements, iel.id

        merge = Merge.three_way(base, local, remote, aio)

        assert_empty merge.conflicts
        assert_equal ier, merge.merged.elements.find { |i| i.id == ier.id }
        assert_equal iel, merge.merged.elements.find { |i| i.id == iel.id }
      end

      def test_apply_diff_insert_element
        base = build_model(with_elements: 3)
        local = base.insert_element(build_element)
        remote = base.clone

        merged = Merge.three_way(base, local, remote, aio).merged

        assert_equal local, merged
        refute_equal base, merged
      end

      def test_apply_diff_on_model_attributes
        m1 = build_model
        m2 = m1.with(id: Faker::Number.hexadecimal(8))

        merge = Merge.three_way(m1, m2, m1, aio)

        assert_equal 1, merge.base_local_diffs.size
        assert_equal m2, merge.merged
      end

      def test_no_changes
        local = Archimate::DataModel::Model.new(base.to_h)
        remote = Archimate::DataModel::Model.new(base.to_h)

        merge = Merge.three_way(base, local, remote, aio)

        assert_equal base, merge.merged
        assert_equal local, merge.merged
        assert_equal remote, merge.merged
      end

      # Given a local where a diagram has been updated and
      # a remote where the same diagram has been deleted
      # expect that the conflicts set includes the two differences
      def test_find_diagram_delete_update_conflicts
        diagram = base.diagrams.first
        remote = base.with(diagrams: [])
        child = diagram.children.first
        updated_child = child.with(name: child.name.to_s + "-modified")
        local = base.with(
          diagrams: [
            diagram.with(children: [updated_child])
          ]
        )

        merge = Merge.three_way(base, local, remote, aio)
        refute_empty merge.conflicts
        assert_equal base, merge.merged
      end

      # delete: element (ok - if not referenced by other diagrams that was updated)
      # TODO: this sort of implies that the diagram changes are already applied
      def test_delete_element_when_still_referenced_in_remaining_diagrams
        diagram = base.diagrams.first
        child = diagram.children.first

        # update diagram that references child
        remote = base.with(
          diagrams: base.diagrams.map do |i|
            diagram.id == i.id ? i.with(name: "I wuz renamed") : i
          end
        )

        # delete element from local
        local = base.with(
          elements: base.elements.reject { |e| e.id == child.archimate_element }
        )

        merge = Merge.three_way(base, local, remote, aio)

        refute_empty merge.conflicts.map(&:to_s)
        assert_equal base, merge.merged
      end

      # delete: relationship (ok - if source & target also deleted & not referenced by remaining diagrams)
      def test_delete_relationship_when_still_referenced_in_remaining_diagrams
        diagram = base.diagrams.first
        relationship_id = diagram.relationships.first
        # update diagram that references child
        remote = base.with(
          diagrams: base.diagrams.map do |i|
            diagram.id == i.id ? i.with(name: "I wuz renamed") : i
          end
        )
        refute_equal base, remote
        refute_equal base.diagrams.first, remote.diagrams.first
        refute_equal base.diagrams.first.name, remote.diagrams.first.name
        # delete relationship from local
        local = base.with(
          relationships: base.relationships.reject { |r| r.id == relationship_id }
        )
        assert_includes base.relationships.map(&:id), relationship_id
        refute_includes local.relationships.map(&:id), relationship_id

        merge = Merge.three_way(base, local, remote, aio)

        refute_empty merge.conflicts.map(&:to_s)
        assert_equal base, merge.merged
      end

      # delete: element (ok - unless other doc doesn't add relationship which references it)
      # TODO: determine if this is a valid test case
      def xtest_delete_element_when_referenced_in_other_change_set
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

        merge = Merge.three_way(base, local, remote, aio)

        refute merge.conflicts.empty?
        assert_equal base, merge.merged
      end

      def test_handle_bounds_changes
        remote = base.clone
        diagram = base.diagrams.first.clone
        bounds = diagram.children[0].bounds
        diagram.children[0] = diagram.children[0].with(bounds: bounds.with(x: bounds.x + 10.0, y: bounds.y + 10.0))
        updated_diagrams = base.diagrams.reject { |d| d.id == diagram.id }.unshift(diagram)
        local = base.with(diagrams: updated_diagrams)

        merge = Merge.three_way(base, local, remote, aio)

        assert_empty merge.conflicts
        refute_equal base, merge.merged
        assert_equal local, merge.merged
      end
    end
  end
end
