module Archimate
  module Examples
    module Factories
      def build_any_attribute(attribute: nil, prefix: "", value: nil)
        DataModel::AnyAttribute.new(
          attribute: attribute || Faker::Company.buzzword.downcase,
          value: value || Faker::Company.buzzword,
          prefix: prefix
        )
      end

      def build_any_element(element: nil, prefix: "", attributes: [], content: nil, children: [])
        DataModel::AnyElement.new(
          element: element || Faker::Company.buzzword.downcase,
          prefix: prefix,
          attributes: attributes,
          content: content,
          children: children
        )
      end

      def build_bounds(options = {})
        DataModel::Bounds.new(
          x: fetch_or_fake_positive_number(options, :x),
          y: fetch_or_fake_positive_number(options, :y),
          width: fetch_or_fake_positive_number(options, :width),
          height: fetch_or_fake_positive_number(options, :height)
        )
      end

      def build_color(options = {})
        DataModel::Color.new(
          r: options.fetch(:r) { random(0, 255) },
          g: options.fetch(:g) { random(0, 255) },
          b: options.fetch(:b) { random(0, 255) },
          a: options.fetch(:a) { random(0, 100) }
        )
      end

      def build_concern(label: nil, documentation: nil, stakeholders: nil)
        DataModel::Concern.new(
          label: label || DataModel::LangString.new(Faker::Company.buzzword),
          documentation: documentation,
          stakeholders: stakeholders || []
        )
      end

      def build_connection(options = {})
        diagram = options.fetch(:diagram) { build_diagram }
        relationship = options.fetch(:relationship) do
          build_relationship(
            source: build_element,
            target: build_element
          )
        end
        source = options.fetch(:source) { build_view_node(element: relationship&.source, diagram: diagram) }
        target = options.fetch(:target) { build_view_node(element: relationship&.target, diagram: diagram) }

        DataModel::Connection.new(
          id: fetch_or_fake_id(options),
          name: fetch_or_fake_name(options),
          documentation: optional_documentation(options),
          type: options.fetch(:type) { random_element_type },
          source_attachment: options.fetch(:source_attachment, nil),
          bendpoints: options.fetch(:bendpoints, []),
          target_attachment: options.fetch(:target_attachment, nil),
          source: source,
          target: target,
          relationship: relationship,
          style: options.fetch(:style, nil),
          properties: options.fetch(:properties, [])
        )
      end

      def build_diagram(options = {})
        diagram = DataModel::Diagram.new(
          id: fetch_or_fake_id(options),
          name: fetch_or_fake_name(options),
          viewpoint: options.fetch(:viewpoint, nil),
          documentation: options.fetch(:documentation, nil),
          properties: options.fetch(:properties, []),
          nodes: [],
          connections: [],
          connection_router_type: nil,
          type: options.fetch(:type, nil),
          background: options.fetch(:background, nil)
        )
        diagram.nodes = options.fetch(:nodes) { build_view_nodes(diagram: diagram) }
        diagram
      end

      def build_diagram_list(options)
        elements = options.fetch(:elements, [])
        relationships = options.fetch(:relationships, [])
        count = options.fetch(:with_diagrams, 0)
        (1..count).map do
          diagram = build_diagram(nodes: [])
          diagram.nodes = relationships.map do |rel|
            [build_view_node(diagram: diagram, element: elements.find { |i| i == rel.source }, relationships: [rel]),
             build_view_node(diagram: diagram, element: elements.find { |i| i == rel.target }, relationships: [])]
          end.flatten
          diagram
        end
      end

      def build_documentation(options = {})
        DataModel::PreservedLangString.new(lang_hash: {"en" => "Something", "es" => "Hola"}, default_lang: "en", default_text: "Something")
      end

      def build_element(options = {})
        cls_name = options.delete(:type)
        if cls_name
          if cls_name.is_a?(Class)
            cls = cls_name
          else
            cls = DataModel::Elements.const_get(cls_name)
          end
        else
          cls = random_element_type
        end
        cls.new(
          id: fetch_or_fake_id(options),
          name: fetch_or_fake_name(options),
          documentation: optional_documentation(options),
          properties: options.fetch(:properties, [])
        )
      end

      def build_element_list(options = {})
        given_elements = options.fetch(:elements, [])
        given_element_count = given_elements.size
        el_count = [options.fetch(:with_relationships, 0) * 2, options.fetch(:with_elements, 0) + given_element_count].max
        count = el_count - given_element_count
        given_elements = given_elements.values if given_elements.is_a? Hash
        (1..count).map { build_element(options) } + given_elements
      end

      def build_font(options = {})
        DataModel::Font.new(
          name: options.fetch(:name) { Faker::Name.name },
          size: options.fetch(:size) { random(6, 20) },
          style: options.fetch(:style) { random(0, 3) },
          font_data: nil
        )
      end

      def build_location(options = {})
        DataModel::Location.new(
          x: options.fetch(:x) { random(0, 1000) },
          y: options.fetch(:y) { random(0, 1000) }
        )
      end

      def build_model(options = {})
        elements = build_element_list(options)
        relationships = build_relationship_list(options.merge(elements: elements))
        diagrams = options.fetch(:diagrams) { build_diagram_list(options.merge(elements: elements, relationships: relationships)) }
        organizations = options.fetch(:organizations) { build_organization_list(options) }
        DataModel::Model.new(
          id: fetch_or_fake_id(options),
          name: fetch_or_fake_name(options),
          documentation: optional_documentation(options),
          properties: options.fetch(:properties, []),
          elements: elements,
          organizations: organizations,
          relationships: relationships,
          property_definitions: options.fetch(:property_definitions, []),
          diagrams: diagrams,
          viewpoints: [],
          filename: options.fetch(:filename, nil),
          file_format: options.fetch(:file_format, nil),
          archimate_version: options.fetch(:archimate_version, :archimate_3_0),
          version: options.fetch(:version, nil),
          namespaces: {},
          schema_locations: []
        ).organize
      end

      def build_organization(options = {})
        DataModel::Organization.new(
          id: fetch_or_fake_id(options),
          name: fetch_or_fake_name(options),
          type: options.fetch(:type, nil),
          documentation: optional_documentation(options),
          items: options.fetch(:items, []),
          organizations: options.fetch(:organizations, [])
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

      def build_preserved_lang_string(options = {})
        DataModel::PreservedLangString.new(
          lang_hash: options.fetch(:lang_hash) { { nil => "##{random(1, 1_000_000)} #{Faker::ChuckNorris.fact}" } },
          default_lang: options.fetch(:default_lang, nil)
        )
      end

      def build_property(options = {})
        value = options.fetch(:value) { Faker::Company.buzzword }
        value = DataModel::LangString.new(value) if value
        DataModel::Property.new(
          value: value,
          property_definition:
            options.fetch(:property_definition) { build_property_definition(name: options.fetch(:key, nil)) }
        )
      end

      def build_property_definition(id: nil, name: nil, documentation: nil, type: "string")
        DataModel::PropertyDefinition.new(
          id: id || build_id,
          name: name || DataModel::LangString.new(Faker::Company.buzzword),
          documentation: documentation,
          type: type
        )
      end

      def build_relationship(options = {})
        cls_name = options.delete(:type)
        if cls_name
          cls_name = cls_name.sub(/Relationship$/, "")
          cls = DataModel::Relationships.const_get(cls_name)
        else
          cls = random_relationship_type
        end
        cls.new(
          id: fetch_or_fake_id(options),
          source: options.fetch(:source) { build_element },
          target: options.fetch(:target) { build_element },
          name: fetch_or_fake_name(options),
          documentation: optional_documentation(options),
          properties: options.fetch(:properties, []),
          access_type: options.fetch(:access_type, nil)
        )
      end

      def build_relationship_list(options = {})
        count = options.fetch(:with_relationships, 0)
        other_rels = options.fetch(:relationships, [])
        elements = options.fetch(:elements, []).dup
        needed_elements = [0, count * 2 - elements.size].max
        elements.concat(build_element_list(with_elements: needed_elements)) unless needed_elements.zero?
        (1..count).map do
          src, target = elements.shift(2)
          build_relationship(source: src, target: target)
        end + other_rels
      end

      def build_style(options = {})
        DataModel::Style.new(
          text_alignment: random(0, 2),
          fill_color: build_color,
          line_color: build_color,
          font_color: build_color,
          line_width: random(1, 10),
          font: build_font,
          text_position: nil
        )
      end

      def build_view_node(options = {})
        diagram = options.fetch(:diagram) { build_diagram }
        node_element = options.fetch(:element) { build_element }
        relationships = options.fetch(:relationships, [])
        with_nodes = build_view_nodes(count: options.delete(:with_nodes) || 0)
        connections = options.fetch(
          :connections,
          relationships.map { |rel| build_connection(relationship: rel) }
        )
        DataModel::ViewNode.new(
          id: fetch_or_fake_id(options),
          type: "archimate:DiagramObject",
          parent: options.fetch(:parent, nil),
          view_refs: nil,
          name: options[:name],
          nodes: options.fetch(:nodes) { with_nodes },
          element: options.fetch(:element) { node_element },
          bounds: options.fetch(:bounds) { build_bounds },
          connections: connections,
          style: build_style,
          child_type: options.fetch(:child_type, nil),
          documentation: options.fetch(:documentation, nil),
          diagram: diagram
        )
      end

      def build_view_nodes(options = {})
        (1..options.fetch(:count, 3)).map { build_view_node(options) }
      end

      ########################################################
      # Diff Builders
      ########################################################

      def build_diff_list(options = {})
        (1..options.fetch(:with_diffs, 3)).map { build_diff(options) }
      end

      def build_diff(options = {})
        model = options.fetch(:model) { build_model }
        Diff::Insert.new(Diff::ArchimateNodeAttributeReference.new(model, :name))
      end

      ########################################################
      # Helpers
      ########################################################

      def build_id
        Faker::Number.hexadecimal(8)
      end

      def fetch_or_fake_id(options = {})
        options.fetch(:id) { build_id }
      end

      def fetch_or_fake_name(options)
        DataModel::LangString.new(options.fetch(:name) { Faker::Company.buzzword })
      end

      def fetch_or_fake_positive_number(options, key)
        options.fetch(key) { Faker::Number.positive }
      end

      def optional_documentation(options)
        attrs = options[:documentation]
        return nil unless attrs
        DataModel::PreservedLangString.new(attrs)
      end

      def random(min, max)
        @random ||= Random.new(Random.new_seed)
        @random.rand(max - min) + min
      end

      def random_element_type
        @random ||= Random.new(Random.new_seed)
        @el_types ||= Archimate::DataModel::Elements.classes
        @el_types[@random.rand(@el_types.size)]
      end

      def random_relationship_type
        @random ||= Random.new(Random.new_seed)
        @rel_types ||= Archimate::DataModel::Relationships.classes
        @rel_types[@random.rand(@rel_types.size)]
      end
    end
  end
end
