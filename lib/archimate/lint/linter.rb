# frozen_string_literal: true
module Archimate
  module Lint
    # lint notes
    #
    # [x] Unused element (not used in a view)
    # [x] Unused relation (not used in a view)
    # [x] Object in a Viewpoint (invalid object for viewpoint)
    # [x] Duplicate same name for type
    # [x] empty view
    # [?] visual nesting without relationship
    # [ ] Warn about sketch model
    # [x] warn about names with (copy)
    # [x] blank element names
    class Linter
      attr_reader :model

      def initialize(model)
        @model = model
        @indent = "\n" + " " * 8
      end

      # TODO: consider a means to sort lint issues by entity instead of lint category
      #       this would point out the particularly problematic items that could be
      #       dealt with appropriately.
      def report(output_io)
        [
          [unused_elements, "Unused Element"],
          [duplicate_elements, "Duplicate Items"],
          [entity_naming_rules, "Naming Rules"],
          [unused_relationships, "Unused Relationship"],
          [duplicate_relationships, "Duplicate Relationships"],
          [empty_views, "Empty View"],
          [invalid_for_viewpoint, "Invalid Type for Viewpoint"],
          [nesting_without_relation, "Visual Nesting"]
        ]
          .map { |issues, title| issues.map { |issue| "#{title}: #{format_issue(issue)}" } }
          .tap { |issues| report_subsection(issues, output_io) }
          .tap { |issues| output_io.puts("Total Issues: #{issues.flatten.size}") }
      end

      def format_issue(issue)
        ary = Array(issue)
        return issue if ary.size == 1
        "#{@indent}#{ary.join(@indent)}"
      end

      def report_subsection(issues, output_io)
        issues.each do |sub_issues|
          output_io.puts(sub_issues)
          output_io.puts("Sub Total: #{sub_issues.size}") unless sub_issues.empty?
        end
      end

      def unused_elements
        referenced_elements = model.diagrams.inject([]) { |memo, dia| memo.concat(dia.elements) }.uniq
        model.elements.reject { |el| referenced_elements.include?(el) }
      end

      def unused_relationships
        referenced_relationships = model.diagrams.inject([]) { |memo, dia| memo.concat(dia.relationships) }.uniq
        model.relationships.reject { |el| referenced_relationships.include?(el) }
      end

      def empty_views
        model.diagrams.select { |diagram| diagram.nodes.empty? }
      end

      def duplicate_elements
        duplicates(model.elements, ->(el) { [el.type, name_for_comparison(el.name)] })
      end

      def duplicate_relationships
        duplicates(model.relationships, ->(el) { [el.type, el.source, el.target, name_for_comparison(el.name)] })
      end

      def name_for_comparison(name)
        name&.strip&.downcase
      end

      def duplicates(array, group_by_proc)
        array
          .group_by { |el| group_by_proc.call(el) }
          .each_with_object([]) do |(_key, ary), dupes|
            dupes << ary.map(&:to_s) if ary.size > 1
          end
      end

      def invalid_for_viewpoint
        model.diagrams.each_with_object([]) do |diagram, errors|
          next if diagram.total_viewpoint?
          valid_entity_types = DataModel::ViewpointType::VIEWPOINTS[diagram.viewpoint_type][:entities]
          valid_relation_types = DataModel::ViewpointType::VIEWPOINTS[diagram.viewpoint_type][:relations]
          invalid_elements = diagram.all_nodes.reject do |child|
            child.element&.type.nil? || valid_entity_types.include?(child.element&.type)
          end
          invalid_relations = diagram.connections.reject do |sc|
            sc.element&.type.nil? || valid_relation_types.include?(sc.element&.type)
          end
          next unless !invalid_elements.empty? || !invalid_relations.empty?
          errors << format(
            "%s viewpoint %s#{@indent}%s",
            diagram,
            diagram.viewpoint,
            (invalid_elements + invalid_relations).map(&:element).map(&:to_s).join(@indent)
          )
        end
      end

      def nesting_without_relation
        model
          .diagrams
          .flat_map(&:all_nodes) # These are top level view nodes
          .reject { |view_node| !view_node.element || view_node.nodes.empty? } # reject the ones with no child view nodes
          .flat_map { |parent|
            parent
              .nodes
              .select(&:element)
              .map { |child| [parent, child] } } # map into parent-child pairs for children that are elements
          .select { |pair|
            model.relationships.none? { |rel|
              (rel.source.equal?(pair[0]) && rel.target.equal?(pair[1]))
            }
          }
          .map { |pair| "#{pair[1].element} should not nest in #{pair[0].element} without valid relationship"}
      end

      def entity_naming_rules
        model.elements.each_with_object([]) do |entity, errors|
          if entity.name.nil? || entity.name.empty?
            errors << "#{entity} name is empty"
          elsif entity.name.size < 2
            errors << "#{entity} name #{entity.name} is too short"
          elsif entity.name.include?("(copy)")
            errors << "#{entity} name #{entity.name} contains '(copy)'"
          end
        end
      end
    end
  end
end
