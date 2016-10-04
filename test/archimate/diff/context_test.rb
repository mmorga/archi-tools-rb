# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ContextTest < Minitest::Test
      BASE = File.join(TEST_EXAMPLES_FOLDER, "base.archimate")
      DIFF1 = File.join(TEST_EXAMPLES_FOLDER, "diff1.archimate")

      def test_new
        model1 = build_model
        model2 = build_model
        ctx = Context.new(model1, model2)
        assert_equal model1, ctx.model1
        assert_equal model2, ctx.model2
      end

      def test_diffs
        el2 = build_element
        el2b = el2.with(label: el2.label + "-changed")

        diffs = Context.new(el2, el2b).diffs
        expected = [
          Difference.change("Element<#{el2.id}>/label", el2.label, el2b.label),
        ]
        assert_equal expected, diffs
      end

      def test_diff_elements_with_id_hash
        el1 = build_element
        el2 = build_element
        el3 = build_element
        el4 = build_element
        el2b = el2.with(label: el2.label + "-changed")

        h1 = Archimate.array_to_id_hash([el1, el2, el3])
        h2 = Archimate.array_to_id_hash([el1, el2b, el4])
        diffs = Context.new(h1, h2).diffs
        expected = [
          Difference.change("#{el2.id}/label", el2.label, el2b.label),
          Difference.delete(el3.id, el3),
          Difference.insert(el4.id, el4)
        ]
        assert_equal(expected, diffs)
      end

      def test_equivalent
        folder = build_folder
        folder_diffs = Context.new(folder, folder.dup).diffs
        assert_empty folder_diffs
      end

      def test_diff_name
        f1 = build_folder
        f2 = f1.with(name: f1.name + "changed")
        folder_diffs = Context.new(f1, f2).diffs
        assert_equal [Difference.change("Folder<#{f1.id}>/name", f1.name, f2.name)], folder_diffs
      end

      def test_folder_added
        f1 = build_folder
        added_folder = build_folder
        folders = f1.folders.dup
        folders[added_folder.id] = added_folder
        f2 = f1.with(folders: folders)
        folder_diffs = Context.new(f1, f2).diffs
        assert_equal [Difference.insert("Folder<#{f1.id}>/folders/#{added_folder.id}", added_folder)], folder_diffs
      end

      def test_folder_deleted
        f2 = build_folder
        added_folder = build_folder
        folders = f2.folders.dup
        folders[added_folder.id] = added_folder
        f1 = f2.with(folders: folders)
        folder_diffs = Context.new(f1, f2).diffs
        assert_equal [Difference.delete("Folder<#{f1.id}>/folders/#{added_folder.id}", added_folder)], folder_diffs
      end

      def test_folder_changed
        f1_1 = build_folder
        f1 = build_folder(folders: Archimate.array_to_id_hash(Array(f1_1)))
        folders = f1.folders.dup
        folders[f1_1.id] = f1_1.with(name: f1_1.name + "changed")
        f2 = f1.with(folders: folders)
        folder_diffs = Context.new(f1, f2).diffs
        assert_equal [
          Difference.change("Folder<#{f1.id}>/folders/#{f1_1.id}/name", f1_1.name, f2.folders[f1_1.id].name)
        ], folder_diffs
      end

      def test_relationship_diffs
        r1 = build_relationship
        r2 = r1.with(name: r1.name + "-changed")
        diffs = Context.new(r1, r2).diffs
        expected = [
          Difference.change("Relationship<#{r1.id}>/name", r1.name, r2.name),
        ]
        assert_equal(expected, diffs)
      end

      def test_string_equivalent
        ctx = Context.new("hello", "hello")
        assert_empty ctx.diffs
      end

      def test_string_insert
        ctx = Context.new(nil, "hello")
        assert_equal [Difference.insert("", "hello")], ctx.diffs
      end

      def test_string_delete
        ctx = Context.new("hello", nil)
        assert_equal [Difference.delete("", "hello")], ctx.diffs
      end

      def test_string_change
        ctx = Context.new("base", "change", "test")
        assert_equal [Difference.change("test", "base", "change")], ctx.diffs
      end

      def test_child_diff
        child1 = build_child(name: Faker::Name.name)
        child2 = build_child(name: Faker::Name.name)
        child3 = build_child(name: Faker::Name.name)
        child4 = build_child(name: Faker::Name.name)
        child2b = child2.with(name: child2.name + "-changed")

        h1 = Archimate.array_to_id_hash([child1, child2, child3])
        h2 = Archimate.array_to_id_hash([child1, child2b, child4])
        diffs = Context.new(h1, h2).diffs
        expected = [
          Difference.change("#{child2.id}/name", child2.name, child2b.name),
          Difference.delete(child3.id, child3),
          Difference.insert(child4.id, child4)
        ]
        assert_equal(expected, diffs)
      end

      def test_equivalent
        model1 = Archimate::ArchiFileReader.read(BASE)
        model2 = Archimate::ArchiFileReader.read(BASE)
        ctx = Context.new(model1, model2)
        model_diffs = ctx.diffs
        assert_empty model_diffs
      end

      def test_diff_model_name
        model1 = Archimate::DataModel::Model.create(id: "123", name: "base")
        model2 = Archimate::DataModel::Model.create(id: "123", name: "change")
        model_diffs = Context.new(model1, model2).diffs
        assert_equal [Difference.change("Model<123>/name", "base", "change")], model_diffs
      end

      def test_diff_model_id
        model1 = Archimate::DataModel::Model.create(id: "123", name: "base")
        model2 = Archimate::DataModel::Model.create(id: "321", name: "base")
        model_diffs = Context.new(model1, model2).diffs
        assert_equal [Difference.change("Model<123>/id", "123", "321")], model_diffs
      end

      def test_diff_model_documentation
        model1 = Archimate::DataModel::Model.create(id: "123", name: "base", documentation: %w(documentation1))
        model2 = Archimate::DataModel::Model.create(id: "123", name: "base", documentation: %w(documentation2))
        model_diffs = Context.new(model1, model2).diffs
        assert_equal(
          [
            Difference.delete("Model<123>/documentation/[0]", "documentation1"),
            Difference.insert("Model<123>/documentation/[0]", "documentation2")
          ], model_diffs
        )
      end

      def test_diff_model_elements_same
        model1 = build_model
        model2 = model1.dup
        model_diffs = Context.new(model1, model2).diffs
        assert_empty(model_diffs)
      end

      def test_diff_model_elements_insert
        model1 = build_model(with_elements: 3)
        elements = model1.elements.dup
        ins_el = build_element
        elements[ins_el.id] = ins_el
        model2 = model1.with(elements: elements)
        model_diffs = Context.new(model1, model2).diffs
        assert_equal(
          [
            Difference.insert("Model<#{model1.id}>/elements/#{ins_el.id}", ins_el)
          ], model_diffs
        )
      end

      def test_diff_model_element_changes
        element1 = build_element
        model1 = build_model(elements: Archimate.array_to_id_hash([element1]))
        from_label = element1.label
        element2 = element1.with(label: from_label + "-modified")
        model2 = model1.with(elements: Archimate.array_to_id_hash([element2]))
        model_diffs = Context.new(model1, model2).diffs
        assert_equal(
          [
            Difference.change("Model<#{model1.id}>/elements/#{element1.id}/label", from_label, element2.label)
          ], model_diffs
        )
      end
    end
  end
end
