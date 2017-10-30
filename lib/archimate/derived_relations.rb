# frozen_string_literal: true

module Archimate
  # 5.6.1 Derivation Rule for Structural and Dependency Relationships
  #
  # The structural and dependency relationships can be ordered by 'strength'.
  # Structural relationships are 'stronger' than dependency relationships, and
  # the relationships within these categories can also be ordered by strength:
  #
  # *  Influence (weakest)
  # *  Access
  # *  Serving
  # *  Realization
  # *  Assignment
  # *  Aggregation
  # *  Composition (strongest)
  #
  # Part of the language definition is an abstraction rule that states that two
  # relationships that join at an intermediate element can be combined and
  # replaced by the weaker of the two.
  #
  #   5.6.2 Derivation Rules for Dynamic Relationships
  #
  # For the two dynamic relationships, the following rules apply:
  #
  # *  If there is a flow relationship r from element a to element b, and a
  #    structural relationship from element c to element a, a flow relationship
  #    r can be derived from element c to element b.
  # *  If there is a flow relationship r from element a to element b, and a
  #    structural relationship from element d to element b, a flow relationship
  #    r can be derived from element a to element d.
  #
  # These rules can be applied repeatedly. Informally, this means that the
  # begin and/or endpoint of a flow relationship can be transferred 'backward'
  # in a chain of elements connected by structural relationships. Example 16
  # shows two of the possible flow relationships that can be derived with these
  # rules, given a flow relationship between the two services.
  #
  # This rule also applies for a triggering relationship, but only in
  # combination with an assignment relationship (not with other structural
  # relationships):
  #
  # *  If there is a triggering relationship r from element a to element b, and
  #    an assignment relationship from element c to element a, a triggering
  #    relationship r can be derived from element c to element b.
  # *  If there is a triggering relationship r from element a to element b, and
  #    an assignment relationship from element d to element b, a triggering
  #    relationship r can be derived from element a to element d.
  #
  # Moreover, triggering relationships are transitive:
  #
  # *  If there is a triggering relationship from element a to element b, and a
  #    triggering relationship from element b to element c, a triggering
  #    relationship can be derived from element a to element c.
  class DerivedRelations
    PASS_ALL = ->(_item) { true }
    FAIL_ALL = ->(_item) { false }

    def initialize(model)
      @model = model
    end

    # This returns a set of derived relationships in this model between the
    # elements in the `start_elements` argument, including relationships that
    # pass the `relationship_filter` recursively until either a target_filter
    # is matched and/or the stop_filter is matched.
    #
    # TODO: Rules for derived relations
    #
    # Assumptions:
    #
    # 1. If an existing relation exists for found "derived" relation, it shouldn't
    #    be included in the results.
    # 2. Any path of length 1 inherently identifies an instance of #1 so they can
    #    be skipped.
    #
    # @param start_elements [Array<Element>] collection of starting nodes
    # @param relationship_filter [Boolean, lambda(Relationship) => Boolean]
    #        filter for the kinds of relationships to follow.
    # @param target_filter [lambda(Element) => Boolean] if true, then a derived
    #        relationship is added to the results
    # @param stop_filter [lambda(Element) => Boolean] if true, then relationships
    #        below this element are not followed
    def derived_relations(start_elements, relationship_filter, target_filter, stop_filter = FAIL_ALL)
      traverse(start_elements, relationship_filter, stop_filter)
        .reject(&single_relation_paths) # See #2 above
        .select(&target_relations(target_filter))
        .map(&create_relationship_for_path)
        .uniq { |rel| [rel.type, rel.source, rel.target] }
    end

    def derived_relationship_type(path)
      DataModel::Relationship::WEIGHTS.rassoc(
        path
          .map(&:weight)
          .min
      ).first
    end

    # traverse returns an Array of paths (Array<Relationship>)
    # between each of the start elements and elements that pass the
    # relation_filter.
    #
    # @param start_elements [Array<Element>] initial elements to start the
    #        model traversal
    # @param relation_filter [Proc(Relationship) => Boolean] only relationships
    #        that pass the relation_filter will be followed
    # @param stop_filter [Proc(Element) => Boolean] the traversal will not
    #        proceed further than relationship targets that the stop_filter
    #        returns true for.
    def traverse(start_elements, relation_filter, stop_filter, from_path = [])
      return [] if from_path.size > 100
      start_elements.each_with_object([]) do |el, relations|
        concrete_rels = concrete_relationships(el, relation_filter, from_path)
        relations.concat(
          concrete_rels,
          *derived_relationship_paths(concrete_rels, relation_filter, stop_filter, from_path)
        )
      end
    end

    def element_by_name(name)
      @model.elements.find { |el| el.name.to_s == name.to_s }
    end

    def element_relationships(el)
      @model
        .relationships
        .select { |rel| rel.source.id == el.id }
    end

    private

    def concrete_relationships(el, relation_filter, from_path)
      element_relationships(el)
        .select(&relation_filter)
        .reject { |rel| from_path.include?(rel) }
    end

    def derived_relationship_paths(concrete_rels, relation_filter, stop_filter, from_path)
      concrete_rels
        .reject { |rel| rel.target.nil? || (stop_filter&.call(rel)) }
        .map do |rel|
          traverse([rel.target], relation_filter, stop_filter, from_path + [rel])
            .map { |path| Array(path).unshift(rel) }
        end
    end

    def single_relation_paths
      ->(path) { Array(path).size <= 1 }
    end

    def target_relations(target_filter)
      ->(path) { target_filter.call(path.last.target) }
    end

    def create_relationship_for_path
      lambda do |path|
        DataModel::Relationship.new(
          id: @model.make_unique_id,
          type: derived_relationship_type(path),
          source: path.first.source,
          target: path.last.target,
          derived: true
        )
      end
    end

    def by_relation_uniq_attributes
      ->(rel) { [rel.type, rel.source, rel.target] }
    end
  end
end
