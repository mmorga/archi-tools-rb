module Archimate
  module Diff
    module Hashify
      # TODO: this isn't used. Delete me.
      def self.hashify(thing)
        case thing
        when Dry::Struct
          thing.instance_variables.reject { |i| i == :@schema }.each_with_object({}) do |i, a|
            a[i] = hashify(thing.instance_variable_get(i))
          end
        when Hash
          thing.each_with_object({}) { |(k, v), a| a[k] = hashify(v) }
        when Array
          thing.map { |i| hashify(i) }
        when String, Float, NilClass, Fixnum
          thing
        else
          raise TypeError, "Unexpected type #{thing.class} for hashify"
        end
      end
    end
  end
end
