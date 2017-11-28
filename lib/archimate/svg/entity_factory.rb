# frozen_string_literal: true

module Archimate
  module Svg
    module EntityFactory
      # @todo this is wrong because it depends on `type` attribute
      def make_entity(child, bounds_offset)
        if child.element
          klass_name = child.element.class.name.split("::").last
        else
          klass_name = child.type.sub('archimate:', '')
        end
        Entity.const_get(klass_name).new(child, bounds_offset)
      rescue NameError
        Logging.logger.fatal "Unsupported entity type #{klass_name}"
        raise
      end
      module_function :make_entity
    end
  end
end
