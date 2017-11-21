# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        class ArchiFileWriter3 < Serializer::Archi::ArchiFileWriter
          include Serializer::Archi::Viewpoint3

          def initialize(model)
            super
            @version = model.version || "3.1.1"
          end
        end
      end
    end
  end
end
