# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class OrganizationTest < Minitest::Test
      def setup
        @child_organizations = build_organization_list(with_organizations: 3)
        @f1 = build_organization(id: "123", name: "Sales", type: "Business", organizations: @child_organizations)
        @f2 = build_organization(id: "123", name: "Sales", type: "Business", organizations: @child_organizations)
      end

      def test_factory
        build_organization
      end

      # This one is blowing up with stack-too-deep
      def test_new
        assert_equal "123", @f1.id
        assert_equal "Sales", @f1.name.to_s
        assert_equal "Business", @f1.type
        assert_equal @child_organizations, @f1.organizations
        assert_empty @f1.items
        assert_nil @f1.documentation
      end

      # OK
      def test_build_organizations_empty
        result = build_organization_list(with_organizations: 0)
        assert result.is_a?(Array)
        assert_empty(result)
      end

      def test_build_organization
        f = build_organization(type: "testtype")
        %i[id type].each do |sym|
          assert_instance_of String, f.send(sym)
          refute_empty f.send(sym)
        end
        assert_instance_of LangString, f.name
        refute_empty f.name
        assert_nil f.documentation
        assert_instance_of Array, f.items
        assert_empty f.items
        assert_instance_of Array, f.organizations
        assert_empty f.organizations
      end

      def test_hash
        assert_equal @f1.hash, @f2.hash
      end

      def test_hash_diff
        refute_equal @f1.hash, build_bounds.hash
      end

      def test_operator_eqleql_true
        assert @f1 == @f2
      end

      def test_operator_eqleql_false
        refute @f1 == Organization.new(id: "234", name: LangString.new("Sales"), type: "Business")
      end

      def test_to_s
        assert_match "Organization", @f1.to_s
        assert_match @f1.name, @f1.to_s
      end

      def test_referenced_identified_nodes
        subject = build_organization(
          organizations: [
            build_organization(
              organizations: [
                build_organization(
                  organizations: [],
                  items: %w[k l m].map { |id| build_element(id: id) }
                )
              ],
              items: %w[a b c].map { |id| build_element(id: id) }
            ),
            build_organization(organizations: [], items: %w[d e f].map { |id| build_element(id: id) })
          ],
          items: %w[g h i j].map { |id| build_element(id: id) }
        )

        assert_equal %w[a b c d e f g h i j k l m], subject.referenced_identified_nodes.map(&:id).sort
      end
    end
  end
end
