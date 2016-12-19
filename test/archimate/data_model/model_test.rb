# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ModelTest < Minitest::Test
      ELEMENT_COUNT = 4

      def setup
        @subject = build_model(with_relationships: 2, with_diagrams: 2, with_elements: ELEMENT_COUNT, with_folders: 4)
      end

      def test_build_model
        assert_equal 4, @subject.elements.size
        assert_equal 2, @subject.relationships.size
        assert_equal 2, @subject.diagrams.size
      end

      def test_equality_operator
        m2 = @subject.clone
        assert_equal @subject, m2
      end

      def test_equality_operator_false
        m2 = @subject.with(name: "felix")
        refute_equal @subject, m2
      end

      def test_lookup
        @subject.relationships.each { |r| assert_equal r, @subject.lookup(r.id) }
        @subject.elements.each { |e| assert_equal e, @subject.lookup(e.id) }
        @subject.folders.each { |f| assert_equal f, @subject.lookup(f.id) }
        @subject.diagrams.each do |d|
          assert_equal d, @subject.lookup(d.id)
          refute d.children.empty?
          d.children.each do |c|
            assert_equal c, @subject.lookup(c.id)
            c.source_connections.each do |s|
              assert_equal s, @subject.lookup(s.id)
            end
          end
        end
      end

      def test_clone
        s2 = @subject.clone
        assert_equal @subject, s2
        refute_equal @subject.object_id, s2.object_id
      end

      def test_application_components
        el = build_element(type: "ApplicationComponent")
        elements = @subject.elements + [el]
        model = @subject.with(elements: elements)
        expected = model.elements.select { |e| e.type == "ApplicationComponent" }

        assert_equal expected, model.application_components
      end

      def test_property_keys
        assert [], @subject.property_keys
      end

      def test_find_by_class
        assert_equal [@subject], @subject.find_by_class(Model)
        assert_equal @subject.elements, @subject.find_by_class(Element)
      end

      def test_referenced_identified_nodes
        subject = build_model(
          folders: [
            build_folder(
              folders: [
                build_folder(
                  folders: [
                    build_folder(
                      folders: [],
                      items: %w(a b c)
                    )
                  ],
                  items: %w(d e f)
                ),
                build_folder(folders: [], items: %w(g h i))
              ],
              items: %w(j k)
            )
          ],
          relationships: [
            build_relationship(
              source: "l",
              target: "m"
            )
          ],
          diagrams: [
            build_diagram(
              children: [
                build_child(
                  target_connections: %w(n o),
                  archimate_element: "p",
                  children: [
                    build_child(
                      target_connections: %w(q r),
                      archimate_element: "s"
                    )
                  ],
                  source_connections: [
                    build_source_connection(
                      source: "t",
                      target: "u",
                      relationship: "v"
                    )
                  ]
                )
              ]
            )
          ]
        )

        assert_equal %w(a b c d e f g h i j k l m n o p q r s t u v), subject.referenced_identified_nodes.sort
      end

      def test_find_in_folders_with_no_folders
        subject = @subject.with(folders: [])
        index_hash = subject.instance_variable_get(:@index_hash)
        index_hash.values.each do |item|
          refute subject.find_in_folders(item)
        end
      end

      def test_find_in_folders
        subject = @subject.with(
          folders: [
            build_folder(
              name: "Elements",
              items: @subject.elements[0..1].map(&:id),
              folders: [
                build_folder(
                  name: "Elements",
                  items: @subject.elements[2..-1].map(&:id)
                )
              ]
            ),
            build_folder(
              name: "Relationships",
              items: @subject.relationships.map(&:id)
            ),
            build_folder(
              name: "Diagrams",
              items: @subject.diagrams.map(&:id)
            )
          ]
        )

        subject.elements.each do |el|
          assert_equal "Elements", subject.find_in_folders(el).name
        end
        subject.relationships.each do |el|
          assert_equal "Relationships", subject.find_in_folders(el).name
        end
        subject.diagrams.each do |el|
          assert_equal "Diagrams", subject.find_in_folders(el).name
        end
      end

      def test_default_folder_for_with_no_initial_folders
        folder = @subject.default_folder_for(build_element(type: "BusinessActor"))
        assert_equal "Business", folder.name

        folder = @subject.default_folder_for(build_element(type: "ApplicationComponent"))
        assert_equal "Application", folder.name

        folder = @subject.default_folder_for(build_element(type: "Node"))
        assert_equal "Technology", folder.name

        folder = @subject.default_folder_for(build_element(type: "Goal"))
        assert_equal "Motivation", folder.name

        folder = @subject.default_folder_for(build_element(type: "Gap"))
        assert_equal "Implementation & Migration", folder.name

        folder = @subject.default_folder_for(build_element(type: "Junction"))
        assert_equal "Connectors", folder.name

        folder = @subject.default_folder_for(build_relationship)
        assert_equal "Relations", folder.name

        folder = @subject.default_folder_for(build_diagram)
        assert_equal "Views", folder.name
      end

      def test_default_folder_for_with_initial_folders_by_type
        subject = @subject.with(
          folders: [
            build_folder(type: "business"),
            build_folder(type: "application"),
            build_folder(type: "technology"),
            build_folder(type: "motivation"),
            build_folder(type: "implementation_migration"),
            build_folder(type: "connectors"),
            build_folder(type: "relations"),
            build_folder(type: "diagrams")
          ]
        )
        folder = subject.default_folder_for(build_element(type: "BusinessActor"))
        assert_equal "business", folder.type

        folder = subject.default_folder_for(build_element(type: "ApplicationComponent"))
        assert_equal "application", folder.type

        folder = subject.default_folder_for(build_element(type: "Node"))
        assert_equal "technology", folder.type

        folder = subject.default_folder_for(build_element(type: "Goal"))
        assert_equal "motivation", folder.type

        folder = subject.default_folder_for(build_element(type: "Gap"))
        assert_equal "implementation_migration", folder.type

        folder = subject.default_folder_for(build_element(type: "Junction"))
        assert_equal "connectors", folder.type

        folder = subject.default_folder_for(build_relationship)
        assert_equal "relations", folder.type

        folder = subject.default_folder_for(build_diagram)
        assert_equal "diagrams", folder.type
      end

      def test_default_folder_for_with_initial_folders_by_name
        subject = @subject.with(
          folders: [
            build_folder(name: "Business"),
            build_folder(name: "Application"),
            build_folder(name: "Technology"),
            build_folder(name: "Motivation"),
            build_folder(name: "Implementation & Migration"),
            build_folder(name: "Connectors"),
            build_folder(name: "Relations"),
            build_folder(name: "Diagrams")
          ]
        )
        folder = subject.default_folder_for(build_element(type: "BusinessActor"))
        assert_equal "Business", folder.name

        folder = subject.default_folder_for(build_element(type: "ApplicationComponent"))
        assert_equal "Application", folder.name

        folder = subject.default_folder_for(build_element(type: "Node"))
        assert_equal "Technology", folder.name

        folder = subject.default_folder_for(build_element(type: "Goal"))
        assert_equal "Motivation", folder.name

        folder = subject.default_folder_for(build_element(type: "Gap"))
        assert_equal "Implementation & Migration", folder.name

        folder = subject.default_folder_for(build_element(type: "Junction"))
        assert_equal "Connectors", folder.name

        folder = subject.default_folder_for(build_relationship)
        assert_equal "Relations", folder.name

        folder = subject.default_folder_for(build_diagram)
        assert_equal "Views", folder.name
      end

      def test_make_unique_id
        assert_match /^[a-f0-9]{8}$/, @subject.make_unique_id
      end

      def test_element_move_folders
        base = build_model(
          elements: [
            build_element(id: "1234abcd")
          ],
          folders: [
            build_folder(
              id: "ffff1111",
              name: "Business",
              type: "business",
              folders: [
                build_folder(
                  id: "ffff2222",
                  name: "Red Shirt Folder",
                  items: ["1234abcd"]
                )
              ]
            )
          ]
        )
        local = base.with(
          folders: [
            base.folders[0].with(
              items: ["1234abcd"],
              folders: []
            )
          ]
        )

        result = base.diff(local)

        assert_equal(
          [
            Diff::Insert.new(Archimate.node_reference(local.folders[0].items, 0)),
            Diff::Delete.new(Archimate.node_reference(base.folders[0].folders[0]))
          ],
          result
        )
      end
    end
  end
end
