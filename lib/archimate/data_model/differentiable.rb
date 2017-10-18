# frozen_string_literal: true

module Archimate
  module DataModel
    # Let's talk about diff...
    #
    # Here are my expectations of diff:
    #
    # = Preconditions:
    #
    # 1. self is non-nil
    # 2. self is a class that includes Comparison
    #
    # = Requirements for other
    #
    # Not matching one of these is a programming error.
    #
    # 1. Other is nil
    # 2. Other is an instance of the same class as self
    #
    # = Diff results
    #
    # * Diffing results in a list of Diff instances between +self+ and +other+
    # * Patching the list of diffs against self results in an instance that == +other+
    #
    # = Diff Container
    #
    # A diff container is a top level entity that is meaningful in the user domain
    # for example: [Element], [Relationship], [Diagram]. It collects and groups
    # the smaller diffs into the things that changed by an entity tha makes sense
    # to the user.
    #
    # = Diff structure
    #
    # A diff contains a change to be applied in a particular context.
    #
    # Use cases:
    #
    # 1. Delete a value that is a member of this class. Example: Delete the
    #    +a+ member of a [Color] instance.
    # 2. A non-reference value replacing a value in a class. Example:
    #    Changing the +r+ value of a [Color] with a different value.
    # 3. Updating the value of an attribute of a child. (or child's child)
    # 4. Deleting the value of an attribute of a child. (or child's child)
    # 5. For Array attributes with non-referenceable contents
    #    1. Deleting a value from an array attribute
    #    2. Inserting a value into an array attribute
    #    3. Changing a value in an array attribute
    # 6. For Array attributes with referenceable contents
    #    1. Deleting a value from an array attribute (has an implication on
    #       if the entity is deleted from the model entirely)
    #    2. Inserting a value into an array attribute (may need addtion to the
    #       model)
    #    3. Changing a value in an array attribute (changing the entity id may
    #       require the implications of deletion and insertion as above)
    #
    # When to stop?
    #
    # When digging down into a diff operation, there are some natural stopping
    # points:
    #
    # 1. When there is no more depth to dig
    # 2. When the objects being compared are references to other entities, but
    #    do not belong to the current object being diffed.
    # 3. When the object being diffed is a Diff container unto itself. For
    #    example: When diffing a model, the diff should include the order
    #    of elements referenced in the +elements+ attribute, but shouldn't
    #    continue with the diff of each element itself.
    #
    # = Complications
    #
    # == Object references
    #
    # Since a patch operation produces an new replacement object, object
    # references need to be handled. For example, given an +Element+ with +id=3+
    # if a patch changes this +Element+'s name, then the +Element+ in
    # the model under +Model#elements+ is replaced with a different instance,
    # but a +Relationship+ that references the +Element+ is still pointing at
    # a different instance and needs to be updated.
    Insert = Struct.new(:path, :value)
    Delete = Struct.new(:path)
    Change = Struct.new(:path, :from, :to)

    module Differentiable
      # Computes the diffs between this object and another object of the same type
      #
      # @param other [self.class] another object to compare
      # @return [Array<Diff::Difference>]
      # @raise
      def diff(other)
        return [] if other.nil?
        raise TypeError, "Expected other <#{other.class} to be of type #{self.class}" unless other.is_a?(self.class)

        self.class.attr_names.each_with_object([]) do |k, a|
          val = send(k)
          case val
          when NilClass
            a << Insert.new(k, other[k]) unless other[k].nil?
          when Integer, Float, Hash, String, Symbol
            a.concat(Differentiable.diff_primitive(val, other[k], self, other, k))
          when Differentiable
            a.concat(val.diff(other[k]))
          else
            raise "Unexpected Type for Diff don't know how to diff a #{val.class}"
          end
        end
      end

      def patch(diffs)
        ary = diffs.is_a?(Array) ? diffs : [diffs]
        self.class.new(
          ary.each_with_object(to_h) do |diff, args|
            case diff
            when Delete
              args[diff.path] = nil
            when Insert
              args[diff.path] = diff.value
            when Change
              args[diff.path] = diff.to
            else
              raise "Unexpected diff type #{diff.class} #{diff.inspect}"
            end
          end
        )
      end

      private

      def self.diff_primitive(val, other, from_parent, to_parent, attribute, from_attribute = nil)
        from_attribute = attribute if from_attribute.nil?
        if other.nil?
          return [Delete.new(attribute)]
        end
        raise TypeError, "Expected other #{other.class} to be of type #{val.class}" unless other.is_a?(val.class)
        unless val == other
          return [Change.new(attribute, val, other)]
        end
        []
      end
    end
  end
end
