# This module takes an ArchiMate model and builds a set of relationship quads
# for use in RDF or graph databases.
#
# The approach is to as follows:

# For each element in the model (not under the "Views" folder)
#   (Which looks like this:
#     <element xsi:type="archimate:BusinessProcess" id="0f6c2750"
#       name="Start Provisioning"/>)

#   <0f6c2750> <named> <Start Provisioning>
#   <0f6c2750> <typed> <archimate:BusinessProcess>
#   <0f6c2750> <in_layer> <business>

#   and for relationship
#   <element xsi:type="archimate:AssignmentRelationship" id="a7cc2df6"
#     source="1c524402" target="0f6c2750"/>

#   a couple of options:

#   option 1:

#   <0f6c2750> <targeted_by> <a7cc2df6>
#   <1c524402> <sourced_by> <a7cc2df6>
#   <a7cc2df6> <typed> <archimate:AssignmentRelationship>
#   <a7cc2df6> <sources> <1c524402>
#   <a7cc2df6> <targets> <0f6c2750>

#   option 2:

#   <1c524402> <assigned_to> <0f6c2750>

#   option 3: combine both so you get easier queries but retain the ability to
#             look at properties on the relationship itsef.

# Future ideas:

# Take views and add to the graph so that we can do
# queries based on things that should possibly be added to a diagram or make
# suggestions on things that should be graphed.

# Add in quads for properties

module Archimate
  Quad = Struct.new(:subject, :predicate, :object) do
    def fmt_obj
      if object =~ /[\s\n\r]/
        "\"#{object.gsub("\"", "\\\"").gsub(/[\n\r]/, "\\n")}\""
      else
        "<#{object}>"
      end
    end

    def fmt_subject
      "#{subject.gsub(/[\s\n\r]/, "_")}"
    end

    def to_s
      "<#{fmt_subject}> <#{predicate}> #{fmt_obj} ."
    end
  end

  class Quads
    def from_file(archi_file)
      @doc = Document.read(archi_file)
      quads = @doc.elements.map do |el|
        [named(el),
          typed(el),
          in_layer(el),
          relationships(el),
          documentation(el)
        ]
      end

      puts quads.flatten.compact.uniq.join("\n")
    end

    def named(el)
      el["name"].nil? ? nil : make_quad(el["id"], "named", el["name"])
    end

    def typed(el)
      make_quad(el["id"], "typed", el["xsi:type"])
    end

    def in_layer(el)
      layer = @doc.layer(el)
      return nil if layer.nil?
      make_quad(el["id"], "in_layer", layer)
    end

    def documentation(el)
      docs = []
      el.css("documentation").each do |doc|
        docs << make_quad(el["id"], "documentation", doc.text)
      end
      docs
    end

    def relationships(el)
      return nil if el["source"].nil? || el["target"].nil?

      [
        make_quad(el["source"], predicate(el["xsi:type"]), el["target"]),
        make_quad(el["id"], "sources", el["source"]),
        make_quad(el["id"], "target", el["target"])
      ]
    end

    PREDICATES = {
      "archimate:AssociationRelationship" => %w(associated_with associated_with),
      "archimate:AccessRelationship" => %w(accesses accessed_by),
      "archimate:UsedByRelationship" => %w(used_by uses),
      "archimate:RealisationRelationship" => %w(realizes realized_by),
      "archimate:AssignmentRelationship" => %w(assigned_to assigned_from),
      "archimate:AggregationRelationship" => %w(aggregates aggregated_by),
      "archimate:CompositionRelationship" => %w(composes composed_by),
      "archimate:FlowRelationship" => %w(flows_to flows_from),
      "archimate:TriggeringRelationship" => %w(triggers triggered_by),
      "archimate:GroupingRelationship" => %w(groups grouped_by),
      "archimate:SpecialisationRelationship" => %w(specializes specialized_by),
      "archimate:InfluenceRelationship" => %w(influences influenced)
    }

    def predicate(t)
      if !PREDICATES.include?(t)
        raise "Unexpected relationship name: '#{t}'"
      end
      PREDICATES[t][0]
    end

    def make_quad(subject, predicate, object)
      if subject.nil? || predicate.nil? || object.nil?
        raise "Invalid: subject: #{subject.inspect}, predicate: #{predicate.inspect}, object: #{object.inspect}"
      end
      Quad.new(subject, predicate, object)
    end
  end
end
