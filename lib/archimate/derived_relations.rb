module Archimate
  class DerivedRelations
    PASS_ALL = lambda { |_item| true }
    FAIL_ALL = lambda { |_item| false }

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
        .reject { |path| Array(path).size <= 1 } # See #2 above
        .select { |path| target_filter.call(path.last.target) }
        .map { |path|
          DataModel::Relationship.new(
            id: @model.make_unique_id,
            type: derived_relationship_type(path),
            source: path.first.source,
            target: path.last.target,
            derived: true
          )
        }
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
      start_elements.each_with_object([]) do |el, result|
        immediate_rels = element_relationships(el)
          .select(&relation_filter)
          .reject { |rel| from_path.include?(rel) }

        result.concat(immediate_rels)
        result.concat(
          *immediate_rels
            .reject { |rel| rel.target.nil? || (stop_filter && stop_filter.call(rel)) }
            .map { |rel|
              traverse([rel.target], relation_filter, stop_filter, from_path + [rel])
                .map { |path| Array(path).unshift(rel) }
            }
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
  end
end
