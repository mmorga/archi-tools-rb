# frozen_string_literal: true

module Archimate
  module DataModel
    # Model is the top level parent of an ArchiMate model.
    class Model < IdentifiedNode
      using DataModel::DiffableArray
      using DataModel::DiffablePrimitive

      ARRAY_RE = Regexp.compile(/\[(\d+)\]/)

      # TODO: add original file name and file format
      # TODO: add metadata & property_defs as in Model Exchange Format
      attribute :name, Strict::String
      attribute :elements, Strict::Array.member(Element).default([])
      attribute :folders, Strict::Array.member(Folder).default([])
      attribute :relationships, Strict::Array.member(Relationship).default([])
      attribute :diagrams, Strict::Array.member(Diagram).default([])

      def initialize(attributes)
        super
        @index_hash = {}
        rebuild_index
        self.in_model = self
        self.parent = nil
        organize
      end

      def lookup(id)
        rebuild_index(id) unless @index_hash.include?(id)
        @index_hash[id]
      end

      def register(node, parent)
        node.in_model = self
        node.parent = parent
        @index_hash[node.id] = node
      end

      def deregister(node)
        @index_hash.delete(node.id)
      end

      def find_by_class(klass)
        @index_hash.values.select { |item| item.is_a?(klass) }
      end

      def to_s
        "#{AIO.data_model('Model')}<#{id}>[#{HighLine.color(name, [:white, :underline])}]"
      end

      # TODO: make these DSL like things added dynamically
      def application_components
        elements.select { |element| element.type == "ApplicationComponent" }
      end

      def element_type_names
        elements.map(&:type).uniq
      end

      def elements_with_type(el_type)
        elements.select { |element| element.type == el_type }
      end

      # TODO: make these DSL like things added dynamically
      def all_properties
        @index_hash.values.each_with_object([]) do |i, a|
          a.concat(i.properties) if i.respond_to?(:properties)
        end
      end

      # TODO: refactor to use property def structure instead of separate property objects
      def property_keys
        all_properties.map(&:key).uniq
      end

      # TODO: refactor to use property def structure instead of separate property objects
      def property_def_id(key)
        "propid-#{property_keys.index(key) + 1}"
      end

      # Iterate through the model and ensure that elements, relationships, and
      # diagrams are all present in the model's folders. If an item is missing
      # then move it into the default top-level element for the item type.
      def organize
        # []
        #   .concat(elements)
        #   .concat(relationships)
        #   .concat(diagrams).each do |item|
        #     default_folder_for(item).items << item.id if find_in_folders(item).nil?
        #   end
        self
      end

      def find_in_folders(item, fs = nil)
        (fs || @folders).each do |folder|
          return folder if folder.items.include?(item.id)
          result = find_in_folders(item, folder.folders)
          return result unless result.nil?
        end
        nil
      end

      def default_folder_for(item)
        case item
        when Element
          case item.layer
          when "Business"
            find_default_folder("business", "Business")
          when "Application"
            find_default_folder("application", "Application")
          when "Technology"
            find_default_folder("technology", "Technology")
          when "Motivation"
            find_default_folder("motivation", "Motivation")
          when "Implementation and Migration"
            find_default_folder("implementation_migration", "Implementation & Migration")
          when "Connectors"
            find_default_folder("connectors", "Connectors")
          else
            raise StandardError, "Unexpected Element Layer: #{item.layer.inspect} for item type #{item.type.inspect}"
          end
        when Relationship
          find_default_folder("relations", "Relations")
        when Diagram
          find_default_folder("diagrams", "Views")
        else
          raise StandardError, "Unexpected item type #{item.class}"
        end
      end

      def find_default_folder(type, name)
        folders.find { |f| f.type == type } ||
          folders.find { |f| f.name == name } ||
          add_folder(type, name)
      end

      def add_folder(type, name)
        folder = Folder.new(id: make_unique_id, name: name, type: type)
        folders << folder
        folder
      end

      def make_unique_id
        unique_id = random_id
        unique_id = random_id while @index_hash.key?(unique_id)
        unique_id
      end

      def referenced_identified_nodes
        super.uniq
      end

      private

      def random_id
        @random ||= Random.new
        format("%08x", @random.rand(0xffffffff))
      end

      def rebuild_index(missing_id = :model_creation_event)
        # puts(
        #   "\nrebuild_index for missing id <#{missing_id.inspect}>, was called:\n" \
        #   "    #{Thread.current.backtrace[0..5].map(&:to_s).join("\n    ")}"
        # ) unless missing_id == :model_creation_event
        @index_hash = build_index
      end
    end
  end
end
