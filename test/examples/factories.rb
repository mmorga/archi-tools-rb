module Archimate
  module Examples
    module Factories
      using Archimate::DataModel::DiffableArray
      using Archimate::DataModel::DiffablePrimitive

      def build_id
        Faker::Number.hexadecimal(8)
      end

      def build_property(options = {})
        value = options.fetch(:value, [DataModel::LangString.new(text: Faker::Company.buzzword)])
        if value.is_a?(String)
          value = [DataModel::LangString.new(text: value)]
        end
        property_def = Archimate::DataModel::PropertyDefinition.new(
          id: build_id,
          name: options.fetch(:key, Faker::Company.buzzword),
          documentation: [],
          value_type: "string"
        )
        property = Archimate::DataModel::Property.new(
          values: value,
          property_definition_id: property_def.id
        )
        [property_def, property]
      end

      def build_documentation_list(options = {})
        count = options.fetch(:with_documentation, 1)
        options.fetch(
          :documentation_list,
          (1..count).map { build_documentation(options.fetch(:documentation_opts, {})) }
        )
      end

      def build_documentation(options = {})
        Archimate::DataModel::Documentation.new(
          text: options.fetch(:text, "##{random(1, 1_000_000)} #{Faker::ChuckNorris.fact}"),
          lang: options.fetch(:lang, nil)
        )
      end

      def build_bounds(options = {})
        Archimate::DataModel::Bounds.new(
          x: options.fetch(:x, Faker::Number.positive),
          y: options.fetch(:y, Faker::Number.positive),
          width: options.fetch(:width, Faker::Number.positive),
          height: options.fetch(:height, Faker::Number.positive)
        )
      end

      def build_model(options = {})
        model_id = options.fetch(:id, build_id)
        elements = build_element_list(options)
        relationships = build_relationship_list(options.merge(elements: elements))
        diagrams = options.fetch(:diagrams, build_diagram_list(options.merge(elements: elements, relationships: relationships)))
        organizations = options.fetch(:organizations, build_organization_list(options))
        Archimate::DataModel::Model.new(
          id: model_id,
          name: options.fetch(:name, Faker::Company.name),
          documentation: build_documentation_list(options),
          properties: options.fetch(:properties, []),
          elements: elements,
          organizations: organizations,
          relationships: relationships,
          property_definitions: options.fetch(:property_definitions, []),
          diagrams: diagrams,
          views: options.fetch(:views, DataModel::Views.new(viewpoints: [], diagrams: [])),
          filename: options.fetch(:filename, nil),
          file_format: options.fetch(:file_format, nil),
          archimate_version: options.fetch(:archimate_version, :archimate_3_0),
          version: options.fetch(:version, nil),
          namespaces: {},
          schema_locations: []
        ).organize
      end

      def build_element_list(options)
        given_elements = options.fetch(:elements, [])
        given_element_count = given_elements.size
        el_count = [options.fetch(:with_relationships, 0) * 2, options.fetch(:with_elements, 0) + given_element_count].max
        count = el_count - given_element_count
        given_elements = given_elements.values if given_elements.is_a? Hash
        (1..count).map { build_element(options) } + given_elements
      end

      def build_element(options = {})
        Archimate::DataModel::Element.new(
          id: options.fetch(:id, build_id),
          name: options.fetch(:name, Faker::Company.buzzword),
          type: options.fetch(:type, random_element_type),
          documentation: options.fetch(:documentation, []),
          properties: options.fetch(:properties, [])
        )
      end

      def build_diagram_list(options)
        elements = options.fetch(:elements, [])
        relationships = options.fetch(:relationships, [])
        count = options.fetch(:with_diagrams, 0)
        (1..count).map do
          child_list = relationships.map do |rel|
            [build_view_node(element: elements.find { |i| i.id == rel.source }, relationships: [rel]),
             build_view_node(element: elements.find { |i| i.id == rel.target }, relationships: [])]
          end.flatten
          build_diagram(nodes: child_list)
        end
      end

      def build_diagram(options = {})
        Archimate::DataModel::Diagram.new(
          id: options.fetch(:id, build_id),
          name: options.fetch(:name, Faker::Commerce.product_name),
          viewpoint: options.fetch(:viewpoint, nil),
          documentation: options.fetch(:documentation, build_documentation_list),
          properties: options.fetch(:properties, []),
          nodes: options.fetch(:nodes, build_nodes),
          connections: [],
          connection_router_type: nil,
          type: options.fetch(:type, nil),
          background: options.fetch(:background, nil)
        )
      end

      def build_nodes(options = {})
        (1..options.fetch(:count, 3)).map { build_view_node }
      end

      def build_view_node(options = {})
        node_element = options.fetch(:element, build_element)
        relationships = options.fetch(:relationships, {})
        with_nodes = build_nodes(count: options.delete(:with_nodes) || 0)
        connections = options.fetch(
          :connections,
          relationships.map { |rel| build_connection(for_relationship: rel) }
        )
        Archimate::DataModel::ViewNode.new(
          id: options.fetch(:id, build_id),
          type: "archimate:DiagramObject",
          name: options[:name],
          nodes: options.fetch(:nodes, with_nodes),
          archimate_element: options.fetch(:archimate_element, node_element.id),
          bounds: build_bounds,
          connections: connections,
          target_connections: options.fetch(:target_connections, connections.map(&:target)),
          style: build_style,
          child_type: options.fetch(:child_type, nil)
        )
      end

      def build_connection(options = {})
        relationship = options.fetch(:for_relationship, nil)

        Archimate::DataModel::Connection.new(
          id: options.fetch(:id, build_id),
          name: options.fetch(:name, Faker::Company.catch_phrase),
          type: options.fetch(:type, random_element_type),
          source: options.fetch(:source, relationship&.source || build_id),
          target: options.fetch(:target, relationship&.target || build_id),
          relationship: options.fetch(:relationship, relationship&.id || build_id),
          bendpoints: options.fetch(:bendpoints, [])
        )
      end

      def build_relationship_list(options = {})
        count = options.fetch(:with_relationships, 0)
        other_rels = options.fetch(:relationships, [])
        elements = options.fetch(:elements, [])
        needed_elements = [0, count * 2 - elements.size].max
        elements.concat(build_element_list(with_elements: needed_elements)) unless needed_elements.zero?
        el_ids = elements.map(&:id).each_slice(2).each_with_object([]) { |i, a| a << i }
        (1..count).map do
          src_id, target_id = el_ids.shift
          build_relationship(source: src_id, target: target_id)
        end + other_rels
      end

      def build_relationship(options = {})
        Archimate::DataModel::Relationship.new(
          id: options.fetch(:id, build_id),
          type: options.fetch(:type, random_relationship_type),
          source: options.fetch(:source, build_id),
          target: options.fetch(:target, build_id),
          name: options.fetch(:name, Faker::Company.catch_phrase),
          documentation: options.fetch(:documentation, []),
          properties: options.fetch(:properties, []),
          access_type: options.fetch(:access_type, nil)
        )
      end

      def build_organization_list(options)
        count = options.fetch(:with_organizations, 0)
        (1..count).map do
          build_organization(
            items: options.fetch(:items, []),
            organizations: options.fetch(:child_organizations, [])
          )
        end
      end

      def build_organization(options = {})
        Archimate::DataModel::Organization.new(
          id: options.fetch(:id, build_id),
          name: options.fetch(:name, Faker::Commerce.department),
          type: options.fetch(:type, nil),
          documentation: options.fetch(:documentation, []),
          properties: options.fetch(:properties, []),
          items: options.fetch(:items, []),
          organizations: options.fetch(:organizations, [])
        )
      end

      def build_location(options = {})
        Archimate::DataModel::Location.new(
          x: options.fetch(:x, random(0, 1000)),
          y: options.fetch(:y, random(0, 1000))
        )
      end

      def build_color(options = {})
        Archimate::DataModel::Color.new(
          r: options.fetch(:r, random(0, 255)),
          g: options.fetch(:g, random(0, 255)),
          b: options.fetch(:b, random(0, 255)),
          a: options.fetch(:a, random(0, 100))
        )
      end

      def build_font(options = {})
        Archimate::DataModel::Font.new(
          name: options.fetch(:name, Faker::Name.name),
          size: options.fetch(:size, random(6, 20)),
          style: options.fetch(:style, random(0, 3)),
          font_data: nil
        )
      end

      def build_style(options = {})
        Archimate::DataModel::Style.new(
          text_alignment: random(0, 2),
          fill_color: build_color,
          line_color: build_color,
          font_color: build_color,
          line_width: random(1, 10),
          font: build_font,
          text_position: nil
        )
      end

      def build_diff_list(options = {})
        (1..options.fetch(:with_diffs, 3)).map { build_diff(options) }
      end

      def build_diff(options = {})
        model = options.fetch(:model, build_model)
        Archimate::Diff::Insert.new(Diff::ArchimateNodeAttributeReference.new(model, :name))
      end

      def random_relationship_type
        @random ||= Random.new(Random.new_seed)
        Archimate::DataModel::Constants::RELATIONSHIPS[@random.rand(Archimate::DataModel::Constants::RELATIONSHIPS.size)]
      end

      def random_element_type
        @random ||= Random.new(Random.new_seed)
        Archimate::DataModel::Constants::ELEMENTS[@random.rand(Archimate::DataModel::Constants::ELEMENTS.size)]
      end

      def random(min, max)
        @random ||= Random.new(Random.new_seed)
        @random.rand(max - min) + min
      end
    end
  end
end
