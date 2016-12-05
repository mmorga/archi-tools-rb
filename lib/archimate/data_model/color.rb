# frozen_string_literal: true
module Archimate
  module DataModel
    class Color < NonIdentifiedNode
      attribute :r, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :g, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :b, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :a, Coercible::Int.constrained(lt: 101, gt: -1).optional

      def self.rgba(str)
        return nil if str.nil?
        md = str.match(/#([\da-f]{2})([\da-f]{2})([\da-f]{2})([\da-f]{2})?/)
        return nil unless md
        new(
          r: md[1].to_i(16),
          g: md[2].to_i(16),
          b: md[3].to_i(16),
          a: md[4].nil? ? 100 : (md[4].to_i(16) / 256.0 * 100.0).to_i
        )
      end

      def self.black
        new(r: 0, g: 0, b: 0, a: 100)
      end

      def to_s
        "Color(r: #{r}, g: #{g}, b: #{b}, a: #{a})"
      end

      def to_rgba
        a == 100 ? format("#%02x%02x%02x", r, g, b) : format("#%02x%02x%02x%02x", r, g, b, scaled_alpha)
      end

      private

      def scaled_alpha(max = 255)
        (max * (a / 100.0)).round
      end
    end

    Dry::Types.register_class(Color)
  end
end
