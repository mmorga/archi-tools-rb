# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class ModelTest < Minitest::Test
      def setup
        @subject = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_organizations: 4)
      end

      def test_bare_factory
        subject = build_model
        refute_nil subject
      end

      def test_build_model
        assert_equal 4, @subject.elements.size
        assert_equal 2, @subject.relationships.size
        assert_equal 2, @subject.diagrams.size
      end

      def test_equality_operator
        # m2 = Model.new(@subject.to_h)
        assert_equal @subject, @subject
      end

      def test_equality_operator_false
        m2 = @subject.clone
        m2.instance_variable_set(:@name, LangString.string("felix"))
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

      def test_application_components
        @subject.elements << build_element(type: "ApplicationComponent")
        expected = @subject.elements.select { |e| e.type == "ApplicationComponent" }
        assert_equal expected, @subject.application_components
      end

      def test_find_by_class
        assert_equal [@subject], @subject.find_by_class(Model)
        assert_equal @subject.elements, @subject.find_by_class(Element)
      end

      def test_referenced_identified_nodes
        skip("Until referenced_identified_nodes for model is needed")
        subject = build_model(
          organizations: [
            build_organization(
              organizations: [
                build_organization(
                  organizations: [
                    build_organization(
                      organizations: [],
                      items: %w[a b c].map { |id| build_element(id: id) }
                    )
                  ],
                  items: %w[d e f].map { |id| build_element(id: id) }
                ),
                build_organization(organizations: [], items: %w[g h i].map { |id| build_element(id: id) })
              ],
              items: %w[j k].map { |id| build_element(id: id) }
            )
          ],
          relationships: [
            build_relationship(
              source: build_element(id: "l"),
              target: build_element(id: "m")
            )
          ],
          diagrams: [
            build_diagram(
              nodes: [
                build_view_node(
                  # target_connections: %w[l m].map { |id| build_connection(id: id) },
                  element: build_element(id: "n"),
                  nodes: [
                    build_view_node(
                      # target_connections: %w[o p].map { |id| build_connection(id: id) },
                      element: build_element(id: "q")
                    )
                  ],
                  connections: [
                    build_connection(
                      id: "r",
                      source: build_element(id: "s"),
                      target: build_element(id: "t"),
                      relationship: build_relationship(id: "u")
                    )
                  ]
                )
              ]
            )
          ]
        )

        result = subject.referenced_identified_nodes.map(&:id).sort
        ('a'..'u').to_a.each do |id|
          assert_includes result, id
        end
      end

      def test_find_in_organizations_with_no_organizations
        skip("Until implement or deprecate find_in_organizations")
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
        subject = build_model(
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
        subject = build_model(
          organizations: [
            build_organization(name: LangString.string("Business")),
            build_organization(name: LangString.string("Application")),
            build_organization(name: LangString.string("Technology")),
            build_organization(name: LangString.string("Motivation")),
            build_organization(name: LangString.string("Implementation & Migration")),
            build_organization(name: LangString.string("Connectors")),
            build_organization(name: LangString.string("Relations")),
            build_organization(name: LangString.string("Diagrams"))
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

      def test_organize
        # skip("Until I either re-implement or remove the organize method")
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
