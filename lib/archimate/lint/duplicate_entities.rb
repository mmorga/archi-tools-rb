module Archimate
  module Lint
    class DuplicateEntities
      def initialize(model)
        @model = model
        @dupes = Hash.new { |type_hash, el_type_name| type_hash[el_type_name] = Hash.new { |name_hash, name| name_hash[name] = [] } }
        @count = nil
        @word_count = {}
        @ignored_entity_types = %w(Junction AndJunction OrJunction)
        dupe_list
      end

      def count
        @count ||= @dupes.reduce(0) do |memo, obj|
          memo + obj[1].reduce(0) do |name_count, name_id_hash|
            name_count + name_id_hash[1].size
          end
        end
      end

      def empty?
        count == 0
      end

      # TODO: sort keys by layer, then alphabetical, then connections
      def each(&block)
        @dupes.keys.sort.each do |element_type|
          @dupes[element_type].keys.sort.each do |name|
            block.call(element_type, name, @dupes[element_type][name])
          end
        end
      end

      protected

      # Sort order:
      # 1. Elements then Relationships
      # 2. For Elements
      # 2.1 Order by Layer
      # 2.2 Order by element type name alpha
      # 2.3 Order by element name
      # 3. For Relationships
      # 3.1 Order by relationship type
      # 3.2 Order by relationship name
      # 3.3 Order by source id
      # 3.4 Order by target id
      def sorted_dupes
        # assuming that @dupes is a hash of uniq-ified label to array of entities
        @dupes.values.sort do |a, b|
          a_entity = a.first
          b_entity = b.first
          return a_entity.class.name <=> b_entity.class.name unless a_entity.is_a?(b_entity.class)
          if a_entity.is_a?(DataModel::Element)
            return a_en
          else
          end
        end
      end

      def dupe_list
        @model.entities
          .select { |entity| entity.is_a?(DataModel::Element) || entity.is_a?(DataModel::Relationship) }
          .reject { |entity| @ignored_entity_types.include?(entity.type) }
          .each do |entity|
          @dupes[entity.type][simplify(entity)] << entity
        end
        @dupes.delete_if do |_el_type, name_entities|
          name_entities.delete_if { |_name, entities| entities.size <= 1 }
          name_entities.size.zero?
        end
        # puts "\n\nWords I found:"
        # @word_count.sort_by(&:last).reverse.each { |ak, av| puts "#{ak}: #{av}" }
        # puts "\n\n"
        @dupes
      end

      # This method takes an entity name and simplifies it for duplicate determination
      # This might be configurable in the future
      # 1. names are explicitly identical
      # 2. names differ only in case
      # 3. names differ only in whitespace
      # 4. names differ only in punctuation
      # 5. TODO: names differ only by stop-words (TBD list of words such as "the", "api", etc.)
      def simplify(entity)
        name = entity.name || ""
        name = name.downcase.gsub(/[[:punct:]]/, "").strip
        # name.split(/\s/).each { |word| @word_count[word] = @word_count.fetch(word, 0) + 1 }
        name = name.delete(" \t\n\r")
        name = "#{name}:#{entity.source}:#{entity.target}" if entity.is_a?(DataModel::Relationship)
        name
      end
    end
  end
end
