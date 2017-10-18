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
            [
              event(
                event_name,
                DataModel::Color.new(
                  %w[r g b a].each_with_object({}) { |attr, hash| hash[attr.to_sym] = attrs[attr]&.to_i }
                )
              )
            ]
          end

          private

          def event_name
            "on_#{snake_case(@name)}".to_sym
          end

          def snake_case(str)
            str.gsub(/([A-Z])/, '_\1').downcase
          end
        end
      end
    end
  end
end
