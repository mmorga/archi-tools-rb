module Archimate
  class Duper
    def get_dupe_list
      dupes = Hash.new { |hash, el_type_name| hash[el_type_name] = Hash.new { |hash2, name| hash2[name] = []} }
      @doc.element_type_names().each do |el_type|
        @doc.elements_with_type(el_type).each do |node|
          dupes[el_type.to_s][@doc.element_label(node)] << @doc.element_identifier(node)
        end
      end
      dupes.delete_if do |key, val|
        val.delete_if {|k2, v2| v2.size <= 1}
        val.size == 0
      end
      dupes
    end

    def list_dupes(archi_file)
      @doc = Document.read(archi_file)
      dupes = get_dupe_list

      count = dupes.reduce(0) {|memo, obj|
        memo + obj[1].reduce(0) {|m2, o2|
          m2 + o2[1].size
        }
      }

      dupes.keys.each do |element_type|
        dupes[element_type].keys.each do |name|
          puts "The name '#{name}' is used more than once for the type '#{element_type}'. Identifiers: #{dupes[element_type][name].inspect}"
        end
      end
      puts "Total Possible Duplicates: #{count}"
    end

    # TODO: Ask what to do with dupes: Possibilities: Merge, Rename, Nothing.
    def ask_to_merge(name)
      true
    end

    # 1. Determine which one is the *original*
    def pick_original(element_type, name, ids)
      # TODO: ask for which one based on folder, comparison, etc
      ids.first
    end

    def merge_into(original, copy)
      copy.elements.each do |child|
        # TODO: is there a better test than this?
        if original.children.none? {|original_child| child.to_xml == original_child.to_xml }
          child.parent = original
        end
      end
    end
    # 2. Copy any attributes/docs, etc. from each of the others into the original.
    #     1. Child `label`s with different `xml:lang` attribute values
    #     2. Child `documentation` (and different `xml:lang` attribute values)
    #     3. Child `properties`
    #     4. Any other elements
    def merge_copies(original_id, copies_ids)
      original = @doc.element_by_identifier(original_id)
      copies_ids.each do |copy_id|
        copy = @doc.element_by_identifier(copy_id)
        merge_into(original, copy)
      end
    end

    # 3. Delete the copy element from the document
    def remove_copies(copies_ids)
      copies_ids.each do |copy_id|
        @doc.element_by_identifier(copy_id).remove
      end
    end

    # 4. For each copy, change references from copy id to original id
    #     1. `relationship`: `source` & `target` attributes
    #     2. `property`: `identifierref` attribute
    #     3. `item`: `identifierref` attribute
    #     4. `node`: `elementref` attribute
    #     5. `connection`: `relationshipref`, `source`, `target` attributes
    def update_associations(original_id, copies_ids)
      copies_ids.each do |copy_id|
        @doc.elements_with_attribute_value(copy_id).each do |node|
          attrs = node.attributes
          attrs.delete("identifier") # We shouldn't get a match here, but would be a bug
          attrs.each do |_attr_name, attr|
            attr.value = original_id if attr.value == copy_id
          end
        end
      end
    end

    def merge(archi_file)
      @doc = Document.read(archi_file)
      dupes = get_dupe_list
      if dupes.empty?
        puts "No potential duplicates detected"
        return
      end

      # TODO: sort keys by layer, then alphabetical, then connections
      dupes.keys.each do |element_type|
        dupes[element_type].keys.sort.each do |name|
          next unless ask_to_merge(name)
          original_id = pick_original(element_type, name, dupes[element_type][name])
          copies_ids = dupes[element_type][name].reject{|id| id == original_id}
          merge_copies(original_id, copies_ids)
          remove_copies(copies_ids)
          update_associations(original_id, copies_ids)
        end
      end

      # TODO: use a destination filename for this method
      @doc.save_as("deduped.xml")
    end
  end
end
