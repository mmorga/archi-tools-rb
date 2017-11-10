# frozen_string_literal: true

module Archimate
  module Svg
    module EntityFactory
      def make_entity(child, bounds_offset)
        entity = child.element || child
        klass_name = entity.type.sub('archimate:', '')
        klass = Archimate::Svg::Entity.const_get(klass_name)
        klass.new(child, bounds_offset)
      rescue NameError
        puts "Unsupported entity type #{klass_name}"
      end
      module_function :make_entity
    end
  end
end
