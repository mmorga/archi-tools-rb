# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        class ArchiFileWriter4 < Serializer::Archi::ArchiFileWriter
          include Serializer::Archi::Viewpoint4

          def initialize(model)
            super
            @version = model.version || "4.0.0"
          end
        end
      end
    end
  end
end
