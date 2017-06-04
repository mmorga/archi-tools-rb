# frozen_string_literal: true

module Archimate
  module Svg
    module EntityFactory
      def make_entity(child, bounds_offset)
        entity = child.element || child
        klass_name = "Archimate::Svg::Entity::#{entity.type.sub('archimate:', '')}"
        klass = Object.const_get(klass_name)
        klass.new(child, bounds_offset)
      rescue
        puts "Unsupported entity type #{klass_name}"
      end
      module_function :make_entity
    end
  end
end
