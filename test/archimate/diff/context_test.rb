# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ContextTest < Minitest::Test
      attr_accessor :base, :local

      BASE = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")
      DIFF1 = File.join(TEST_EXAMPLES_FOLDER, "diff1.archimate")

      def setup
        @base = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        @local = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
      end

      def test_new
        ctx = Context.new(base, local, @base, @local)
        assert_equal @base, ctx.base
        assert_equal @local, ctx.local
      end

      def test_diff_element_label
        el2 = build_element
        el2b = el2.with(label: el2.label + "-changed")

        diffs = Context.new(base, local, el2, el2b).diffs
        expected = [
          Change.new("label", base, local, el2.label, el2b.label)
        ]
        assert_equal expected, diffs
      end

      def test_diff_elements_with_change_delete_insert
        el1 = build_element
        el2 = build_element
        el3 = build_element
        el4 = build_element
        el2b = el2.with(label: el2.label + "-changed")
        h1 = [el1, el2, el3]
        h2 = [el1, el2b, el4]
        expected = [
          Change.new("[1]/label", base, local, el2.label, el2b.label),
          Delete.new("[2]", base, el3),
          Insert.new("[2]", local, el4)
        ]

        diffs = Context.new(base, local, h1, h2).diffs

        assert_equal expected.map(&:to_s), diffs.map(&:to_s)
        assert_equal expected, diffs
      end

      def test_diff_element_labels_in_list
        el1 = build_element
        el2 = build_element
        el2b = el2.with(label: el2.label + "-changed")

        l1 = [el1, el2]
        l2 = [el1, el2b]
        diffs = Context.new(base, local, l1, l2).diffs
        expected = [
          Change.new("[1]/label", base, local, el2.label, el2b.label)
        ]
        assert_equal expected, diffs
      end

      def test_folders_equivalent
        folder = build_folder
        folder_diffs = Context.new(base, local, folder, folder.dup).diffs
        assert_empty folder_diffs
      end

      def test_diff_name
        f1 = build_folder
        f2 = f1.with(name: f1.name + "changed")

        folder_diffs = Context.new(base, local, f1, f2).diffs

        assert_equal [Change.new("name", base, local, f1.name, f2.name)], folder_diffs
      end

      def test_folder_added
        f1 = build_folder
        added_folder = build_folder
        folders = f1.folders.dup
        folders << added_folder
        f2 = f1.with(folders: folders)
        expected = [Insert.new("folders/[0]", local, added_folder)]

        folder_diffs = Context.new(base, local, f1, f2).diffs

        assert_equal expected.map(&:to_s), folder_diffs.map(&:to_s)
        assert_equal expected, folder_diffs
      end

      def test_folder_deleted
        f2 = build_folder
        assert_empty f2.folders
        deleted_folder = build_folder
        f1 = f2.with(folders: [deleted_folder])
        expected = [Delete.new("folders/[0]", base, deleted_folder)]

        diffs = Context.new(base, local, f1, f2).diffs

        refute_equal diffs[0], diffs[1]
        assert_equal expected.map(&:to_s), diffs.map(&:to_s)
        assert_equal expected, diffs
      end

      def test_folder_changed
        testing_folder = build_folder
        changed_folder = testing_folder.with(name: testing_folder.name + "changed")
        parent_folder = build_folder(folders: [testing_folder])
        base = build_model(folders: [parent_folder])
        local = base.with(
          folders: [
            parent_folder.with(
              folders: [
                changed_folder
              ]
            )
          ]
        )

        folder_diffs = Context.new(base, local, base.folders.first, local.folders.first).diffs
        assert_equal [
          Change.new("folders/[0]/name", base, local, testing_folder.name, changed_folder.name)
        ], folder_diffs
      end

      def test_relationship_diffs
        r1 = build_relationship
        r2 = r1.with(name: r1.name + "-changed")
        expected = [
          Change.new("name", base, local, r1.name, r2.name)
        ]

        diffs = Context.new(base, local, r1, r2).diffs

        assert_equal(expected, diffs)
      end

      def test_string_equivalent
        ctx = Context.new(base, local, "hello", "hello")
        assert_empty ctx.diffs
      end

      def test_string_insert
        ctx = Context.new(base, local, nil, "hello")
        assert_equal [Insert.new("", local, "hello")], ctx.diffs
      end

      def test_string_delete
        ctx = Context.new(base, local, "hello", nil)
        assert_equal [Delete.new("", base, "hello")], ctx.diffs
      end

      def test_string_change
        ctx = Context.new(base, local, "base", "change", "test")
        assert_equal [Change.new("test", base, local, "base", "change")], ctx.diffs
      end

      def test_child_diff
        child1 = build_child(name: Faker::Name.name)
        child2 = build_child(name: Faker::Name.name)
        child3 = build_child(name: Faker::Name.name)
        child4 = build_child(name: Faker::Name.name)
        child2b = child2.with(name: child2.name + "-changed")
        h1 = [child1, child2, child3]
        h2 = [child1, child2b, child4]
        expected = [
          Change.new("[1]/name", base, local, child2.name, child2b.name),
          Delete.new("[2]", base, child3),
          Insert.new("[2]", local, child4)
        ]

        diffs = Context.new(base, local, h1, h2).diffs

        assert_equal expected.map(&:to_s), diffs.map(&:to_s)
        assert_equal(expected, diffs)
      end

      def test_models_equivalent
        model1 = Archimate::ArchiFileReader.read(BASE)
        model2 = Archimate::ArchiFileReader.read(BASE)
        ctx = Context.new(base, local, model1, model2)
        model_diffs = ctx.diffs
        assert_empty model_diffs
      end

      def test_diff_model_name
        model1 = Archimate::DataModel::Model.create(id: "123", name: "base")
        model2 = Archimate::DataModel::Model.create(id: "123", name: "change")
        model_diffs = Context.new(base, local, model1, model2).diffs
        assert_equal [Change.new("Model<123>/name", base, local, "base", "change")], model_diffs
      end

      def test_diff_model_id
        model1 = Archimate::DataModel::Model.create(id: "123", name: "base")
        model2 = Archimate::DataModel::Model.create(id: "321", name: "base")
        model_diffs = Context.new(base, local, model1, model2).diffs
        assert_equal [Change.new("Model<123>/id", base, local, "123", "321")], model_diffs
      end

      def test_diff_model_documentation
        doc1 = build_documentation_list
        doc2 = build_documentation_list
        model1 = Archimate::DataModel::Model.create(id: "123", name: "base", documentation: doc1)
        model2 = Archimate::DataModel::Model.create(id: "123", name: "base", documentation: doc2)
        expected = [
          Delete.new("Model<123>/documentation/[0]", base, doc1.first),
          Insert.new("Model<123>/documentation/[0]", local, doc2.first)
        ]

        diffs = Context.new(base, local, model1, model2).diffs

        assert_equal expected.map(&:to_s), diffs.map(&:to_s)
        assert_equal expected, diffs
      end

      def test_diff_model_elements_same
        model1 = build_model
        model2 = model1.dup
        model_diffs = Context.new(base, local, model1, model2).diffs
        assert_empty(model_diffs)
      end

      def test_diff_model_elements_insert
        model1 = build_model(with_elements: 3)
        elements = model1.elements.dup
        ins_el = build_element
        elements << ins_el
        model2 = model1.with(elements: elements)
        expected = [Insert.new("Model<#{model1.id}>/elements/[3]", local, ins_el)]

        diffs = Context.new(base, local, model1, model2).diffs

        assert_equal expected.map(&:to_s), diffs.map(&:to_s)
        assert_equal expected, diffs
      end

      def test_diff_model_element_changes
        element1 = build_element
        model1 = build_model(elements: [element1])
        from_label = element1.label
        element2 = element1.with(label: from_label + "-modified")
        model2 = model1.with(elements: [element2])
        model_diffs = Context.new(base, local, model1, model2).diffs
        assert_equal(
          [
            Change.new("Model<#{model1.id}>/elements/[0]/label", base, local, from_label, element2.label)
          ], model_diffs
        )
      end

      def test_array_diff_finding
        assert_equal 4, @base.elements.size
        @local = @base.with(elements: @base.elements[1..-1])

        model_diffs = Context.new(base, local, base, local).diffs

        assert_equal(
          [
            Delete.new("Model<#{@base.id}>/elements/[0]", base, base.elements.first)
          ], model_diffs
        )
      end
    end
  end
end
