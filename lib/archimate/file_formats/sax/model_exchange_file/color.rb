# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class Color < Sax::Handler
          def initialize(name, attrs, parent_handler)
            super
          end

          def complete
            color = DataModel::Color.new(
              r: attrs["r"]&.to_i,
              g: attrs["g"]&.to_i,
              b: attrs["b"]&.to_i,
              a: attrs["a"]&.to_i
            )
            [event("on_#{@name}".to_sym, color)]
          end
        end
      end
    end
  end
end
