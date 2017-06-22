# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class ModelTest < Minitest::Test
      ELEMENT_COUNT = 4

      def setup
        @subject = build_model(with_relationships: 2, with_diagrams: 2, with_elements: ELEMENT_COUNT, with_organizations: 4)
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
        @subject.organizations.each { |f| assert_equal f, @subject.lookup(f.id) }
        @subject.diagrams.each do |d|
          assert_equal d, @subject.lookup(d.id)
          refute d.nodes.empty?
          d.nodes.each do |c|
            assert_equal c, @subject.lookup(c.id)
            c.connections.each do |s|
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
          organizations: [
            build_organization(
              organizations: [
                build_organization(
                  organizations: [
                    build_organization(
                      organizations: [],
                      items: %w[a b c]
                    )
                  ],
                  items: %w[d e f]
                ),
                build_organization(organizations: [], items: %w[g h i])
              ],
              items: %w[j k]
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
              nodes: [
                build_view_node(
                  target_connections: %w[n o],
                  archimate_element: "p",
                  nodes: [
                    build_view_node(
                      target_connections: %w[q r],
                      archimate_element: "s"
                    )
                  ],
                  connections: [
                    build_connection(
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

        # assert_equal ('a'..'v').to_a + subject.elements.map(&:id), subject.referenced_identified_nodes.sort
        result = subject.referenced_identified_nodes.sort
        # assert_equal ('a'..'v').to_a, subject.referenced_identified_nodes.sort
        ('a'..'v').to_a.each do |id|
          assert_includes result, id
        end
      end

      def xtest_find_in_organizations_with_no_organizations
        subject = @subject.with(organizations: [])
        index_hash = subject.instance_variable_get(:@index_hash)
        index_hash.values.each do |item|
          refute subject.find_in_organizations(item)
        end
      end

      def test_find_in_organizations
        @subject.elements.each do |el|
          assert_kind_of DataModel::Organization, @subject.find_in_organizations(el)
        end
        @subject.relationships.each do |el|
          assert_equal "Relations", @subject.find_in_organizations(el).name.to_s
        end
        @subject.diagrams.each do |el|
          assert_equal "Views", @subject.find_in_organizations(el).name.to_s
        end
      end

      def test_default_organization_for_with_no_initial_organizations
        organization = @subject.default_organization_for(build_element(type: "BusinessActor"))
        assert_equal "Business", organization.name.to_s

        organization = @subject.default_organization_for(build_element(type: "ApplicationComponent"))
        assert_equal "Application", organization.name.to_s

        organization = @subject.default_organization_for(build_element(type: "Node"))
        assert_equal "Technology", organization.name.to_s

        organization = @subject.default_organization_for(build_element(type: "Goal"))
        assert_equal "Motivation", organization.name.to_s

        organization = @subject.default_organization_for(build_element(type: "Gap"))
        assert_equal "Implementation & Migration", organization.name.to_s

        organization = @subject.default_organization_for(build_element(type: "Junction"))
        assert_equal "Connectors", organization.name.to_s

        organization = @subject.default_organization_for(build_relationship)
        assert_equal "Relations", organization.name.to_s

        organization = @subject.default_organization_for(build_diagram)
        assert_equal "Views", organization.name.to_s
      end

      def test_default_organization_for_with_initial_organizations_by_type
        subject = @subject.with(
          organizations: [
            build_organization(type: "business"),
            build_organization(type: "application"),
            build_organization(type: "technology"),
            build_organization(type: "motivation"),
            build_organization(type: "implementation_migration"),
            build_organization(type: "connectors"),
            build_organization(type: "relations"),
            build_organization(type: "diagrams")
          ]
        )
        organization = subject.default_organization_for(build_element(type: "BusinessActor"))
        assert_equal "business", organization.type

        organization = subject.default_organization_for(build_element(type: "ApplicationComponent"))
        assert_equal "application", organization.type

        organization = subject.default_organization_for(build_element(type: "Node"))
        assert_equal "technology", organization.type

        organization = subject.default_organization_for(build_element(type: "Goal"))
        assert_equal "motivation", organization.type

        organization = subject.default_organization_for(build_element(type: "Gap"))
        assert_equal "implementation_migration", organization.type

        organization = subject.default_organization_for(build_element(type: "Junction"))
        assert_equal "connectors", organization.type

        organization = subject.default_organization_for(build_relationship)
        assert_equal "relations", organization.type

        organization = subject.default_organization_for(build_diagram)
        assert_equal "diagrams", organization.type
      end

      def test_default_organization_for_with_initial_organizations_by_name
        subject = @subject.with(
          organizations: [
            build_organization(name: "Business"),
            build_organization(name: "Application"),
            build_organization(name: "Technology"),
            build_organization(name: "Motivation"),
            build_organization(name: "Implementation & Migration"),
            build_organization(name: "Connectors"),
            build_organization(name: "Relations"),
            build_organization(name: "Diagrams")
          ]
        )
        organization = subject.default_organization_for(build_element(type: "BusinessActor"))
        assert_equal "Business", organization.name.to_s

        organization = subject.default_organization_for(build_element(type: "ApplicationComponent"))
        assert_equal "Application", organization.name.to_s

        organization = subject.default_organization_for(build_element(type: "Node"))
        assert_equal "Technology", organization.name.to_s

        organization = subject.default_organization_for(build_element(type: "Goal"))
        assert_equal "Motivation", organization.name.to_s

        organization = subject.default_organization_for(build_element(type: "Gap"))
        assert_equal "Implementation & Migration", organization.name.to_s

        organization = subject.default_organization_for(build_element(type: "Junction"))
        assert_equal "Connectors", organization.name.to_s

        organization = subject.default_organization_for(build_relationship)
        assert_equal "Relations", organization.name.to_s

        organization = subject.default_organization_for(build_diagram)
        assert_equal "Views", organization.name.to_s
      end

      def test_make_unique_id
        assert_match(/^[a-f0-9]{8}$/, @subject.make_unique_id)
      end

      def test_element_move_organizations
        base = build_model(
          elements: [
            build_element(id: "1234abcd", type: "BusinessActor")
          ],
          organizations: [
            build_organization(
              id: "ffff1111",
              name: "Business",
              type: "business",
              organizations: [
                build_organization(
                  id: "ffff2222",
                  name: "Red Shirt Organization",
                  items: ["1234abcd"]
                )
              ]
            )
          ]
        )
        local = base.with(
          organizations: [
            base.organizations[0].with(
              items: ["1234abcd"],
              organizations: []
            )
          ]
        )

        result = base.diff(local)

        assert_equal(
          [
            Diff::Insert.new(Diff::ArchimateArrayReference.new(local.organizations[0].items, 0)),
            Diff::Delete.new(Diff::ArchimateArrayReference.new(base.organizations[0].organizations, 0))
          ],
          result
        )
      end

      def test_organize
        model = build_model
        assert_empty model.organizations

        layer_els = Archimate::DataModel::Constants::LAYER_ELEMENTS
        (1..layer_els.size).each do |i|
          model = build_model(
            elements: (0..(i - 1)).map do |idx|
              build_element(type: layer_els[layer_els.keys[idx]][0])
            end
          )
          assert_equal i, model.organizations.size
        end
      end
    end
  end
end
