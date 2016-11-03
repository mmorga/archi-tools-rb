module Archimate
  module Examples
    module Factories
      def build_id
        Faker::Number.hexadecimal(8)
      end

      def build_property(options = {})
        Archimate::DataModel::Property.new(
          parent_id: options.fetch(:parent_id, build_id),
          key: options.fetch(:key, Faker::Company.buzzword),
          value: options.fetch(:value, Faker::Company.buzzword)
        )
      end

      def build_documentation_list(options = {})
        count = options.fetch(:count, 1)
        options.fetch(
          :documentation_list,
          (1..count).map { build_documentation(options.fetch(:documentation_opts, {})) }
        )
      end

      def build_documentation(options = {})
        Archimate::DataModel::Documentation.new(
          parent_id: options.fetch(:parent_id, build_id),
          text: options.fetch(:text, Faker::ChuckNorris.fact),
          lang: options.fetch(:lang, nil)
        )
      end

      def build_bounds(options = {})
        Archimate::DataModel::Bounds.new(
          parent_id: options.fetch(:parent_id, build_id),
          x: options.fetch(:x, Faker::Number.positive),
          y: options.fetch(:y, Faker::Number.positive),
          width: options.fetch(:width, Faker::Number.positive),
          height: options.fetch(:height, Faker::Number.positive)
        )
      end

      def build_element(options = {})
        Archimate::DataModel::Element.new(
          parent_id: options.fetch(:parent_id, build_id),
          id: options.fetch(:id, build_id),
          label: options.fetch(:label, Faker::Company.buzzword),
          type: options.fetch(:type, random_element_type),
          documentation: options.fetch(:documentation, []),
          properties: options.fetch(:properties, [])
        )
      end

      def build_element_list(options)
        given_elements = options.fetch(:elements, [])
        given_element_count = given_elements.size
        el_count = [options.fetch(:with_relationships, 0) * 2, options.fetch(:with_elements, 0) + given_element_count].max
        count = el_count - given_element_count
        given_elements = given_elements.values if given_elements.is_a? Hash
        bel = (1..count).map { build_element(options) } + given_elements
        Archimate.array_to_id_hash(bel)
      end

      def build_relationship_list(options = {})
        count = options.fetch(:with_relationships, 0)
        other_rels = options.fetch(:relationships, [])
        elements = options.fetch(:elements, {})
        needed_elements = [0, count * 2 - elements.size].max
        elements.merge!(build_element_list(with_elements: needed_elements)) unless needed_elements.zero?
        el_ids = elements.values.map(&:id).each_slice(2).each_with_object([]) { |i, a| a << i }
        Archimate.array_to_id_hash(
          (1..count).map do
            src_id, target_id = el_ids.shift
            build_relationship(source: src_id, target: target_id, parent_id: options.fetch(:parent_id, build_id))
          end + other_rels
        )
      end

      def build_diagram_list(options)
        elements = options.fetch(:elements, {})
        relationships = options.fetch(:relationships, {})
        count = options.fetch(:with_diagrams, 0)
        child_list = relationships.map do |id, rel|
          [build_child(element: elements[rel.source], relationships: { id => rel }),
           build_child(element: elements[rel.target], relationships: {})]
        end.flatten
        Archimate.array_to_id_hash(
          (1..count).map { build_diagram(children: Archimate.array_to_id_hash(child_list), parent_id: options.fetch(:parent_id, build_id)) }
        )
      end

      def build_model(options = {})
        model_id = options.fetch(:id, build_id)
        elements = build_element_list(options.merge(parent_id: model_id))
        relationships = build_relationship_list(options.merge(elements: elements, parent_id: model_id))
        diagrams = build_diagram_list(options.merge(elements: elements, relationships: relationships, parent_id: model_id))
        folders = options.fetch(:folders, build_folder_list(options.merge(parent_id: model_id)))
        Archimate::DataModel::Model.new(
          parent_id: nil,
          id: model_id,
          name: options.fetch(:name, Faker::Company.name),
          documentation: options.fetch(:documentation, []),
          properties: options.fetch(:properties, []),
          elements: elements,
          folders: folders,
          relationships: relationships,
          diagrams: diagrams
        )
      end

      def build_diagram(options = {})
        children = options.fetch(:children, build_children)
        Archimate::DataModel::Diagram.new(
          parent_id: options.fetch(:parent_id, build_id),
          id: options.fetch(:id, build_id),
          name: options.fetch(:name, Faker::Commerce.product_name),
          viewpoint: options.fetch(:viewpoint, nil),
          documentation: options.fetch(:documentation, build_documentation_list),
          properties: options.fetch(:properties, []),
          children: children,
          connection_router_type: nil,
          type: nil,
          element_references: children.each_with_object([]) { |(_id, child), a| a.concat(child.element_references) }
        )
      end

      def build_children(options = {})
        count = options.fetch(:count, 3)
        (1..count).each_with_object({}) do |_i, a|
          child = build_child
          a[child.id] = child
        end
      end

      def build_child(options = {})
        node_element = options.fetch(:element, build_element)
        relationships = options.fetch(:relationships, {})
        with_children = options.delete(:with_children)
        Archimate::DataModel::Child.create(
          parent_id: options.fetch(:parent_id, build_id),
          id: options.fetch(:id, build_id),
          type: "archimate:DiagramObject",
          name: options[:name],
          children: build_children(count: with_children || 0),
          archimate_element: node_element.id,
          bounds: build_bounds,
          source_connections: relationships.values.map do |rel|
            build_source_connection(for_relationship: rel)
          end,
          style: build_style
        )
      end

      def build_source_connection(options = {})
        relationship = options.fetch(:for_relationship, nil)

        Archimate::DataModel::SourceConnection.create(
          parent_id: options.fetch(:parent_id, build_id),
          id: options.fetch(:id, build_id),
          type: options.fetch(:type, random_element_type),
          source: options.fetch(:source, relationship&.source || build_id),
          target: options.fetch(:target, relationship&.target || build_id),
          relationship: options.fetch(:relationship, relationship&.id || build_id)
        )
      end

      def build_relationship(options = {})
        Archimate::DataModel::Relationship.new(
          parent_id: options.fetch(:parent_id, build_id),
          id: options.fetch(:id, build_id),
          type: options.fetch(:type, random_relationship_type),
          source: options.fetch(:source, build_id),
          target: options.fetch(:target, build_id),
          name: options.fetch(:name, Faker::Company.catch_phrase),
          documentation: options.fetch(:documentation, []),
          properties: options.fetch(:properties, [])
        )
      end

      def build_folder(options = {})
        Archimate::DataModel::Folder.new(
          parent_id: options.fetch(:parent_id, build_id),
          id: options.fetch(:id, build_id),
          name: options.fetch(:name, Faker::Commerce.department),
          type: options.fetch(:type, random_relationship_type),
          documentation: options.fetch(:documentation, []),
          properties: options.fetch(:properties, []),
          items: options.fetch(:items, []),
          folders: options.fetch(:folders, {})
        )
      end

      def build_folder_list(options)
        count = options.fetch(:with_folders, 0)
        min_items = 1
        max_items = 10
        (1..count).each_with_object({}) do |_i, a|
          folder = build_folder(
            parent_id: options.fetch(:parent_id, build_id),
            items: (0..random(min_items, max_items)).each_with_object([]) { |_i2, a2| a2 << build_id },
            folders: options.fetch(:child_folders, {})
          )
          a[folder.id] = folder
        end
      end

      def build_bendpoint(options = {})
        Archimate::DataModel::Bendpoint.new(
          parent_id: options.fetch(:parent_id, build_id),
          start_x: options.fetch(:start_x, random(0, 1000)),
          start_y: options.fetch(:start_y, random(0, 1000)),
          end_x: options.fetch(:end_x, random(0, 1000)),
          end_y: options.fetch(:end_y, random(0, 1000))
        )
      end

      def build_color(options = {})
        Archimate::DataModel::Color.new(
          parent_id: options.fetch(:parent_id, build_id),
          r: options.fetch(:r, random(0, 255)),
          g: options.fetch(:g, random(0, 255)),
          b: options.fetch(:b, random(0, 255)),
          a: options.fetch(:a, random(0, 100))
        )
      end

      def build_font(options = {})
        Archimate::DataModel::Font.new(
          parent_id: options.fetch(:parent_id, build_id),
          name: options.fetch(:name, Faker::Name.name),
          size: options.fetch(:size, random(6, 20)),
          style: options.fetch(:style, Faker::Name.name)
        )
      end

      def build_style(options = {})
        Archimate::DataModel::Style.new(
          parent_id: options.fetch(:parent_id, build_id),
          text_alignment: random(0, 2),
          fill_color: build_color,
          line_color: build_color,
          font_color: build_color,
          line_width: random(1, 10),
          font: build_font
        )
      end

      def build_diff_list(options = {})
        (1..options.fetch(:with_diffs, 3)).map { build_diff(options) }
      end

      def build_diff(options = {})
        model = options.fetch(:model, build_model)
        to = options.fetch(:diff_to_value, Faker::Name.name)
        Archimate::Diff::Insert.new(
          options.fetch(:path, "Model<#{model.id}>/name"),
          model,
          to
        )
      end

      def random_relationship_type
        @random ||= Random.new(Random.new_seed)
        Archimate::Constants::RELATIONSHIPS[@random.rand(Archimate::Constants::RELATIONSHIPS.size)]
      end

      def random_element_type
        @random ||= Random.new(Random.new_seed)
        Archimate::Constants::ELEMENTS[@random.rand(Archimate::Constants::ELEMENTS.size)]
      end

      def random(min, max)
        @random ||= Random.new(Random.new_seed)
        @random.rand(max - min) + min
      end
    end
  end
end
