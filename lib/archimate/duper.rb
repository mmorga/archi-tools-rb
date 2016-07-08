require "highline"

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

    def merge_duplicates(original_id, dupe_ids)
      copies_ids = dupe_ids.reject{|id| id == original_id}
      merge_copies(original_id, copies_ids)
      remove_copies(copies_ids)
      update_associations(original_id, copies_ids)
    end

    def display_elements(ids)
      ids.each_with_index do |id, idx|
        puts "#{idx}. #{@doc.stringize(@doc.element_by_identifier(id))}\n"
      end
    end
    # 1. Determine which one is the *original*
    def handle_duplicate(element_type, name, ids)
      display_elements(ids)
      @cli.choose do |menu|
        # TODO: set up a layout that permits showing a repr of the copies
        # to permit making the choice of the original
        menu.header = "There are #{ids.size} #{element_type}s with the name #{name}"
        menu.prompt = "What to do with potential duplicates?"
        menu.choice(:merge, help: "Merge elements into a single element", text: "Merge elements") {
          original_id = ids.first # TODO: let the user choose this
          merge_duplicates(original_id, ids)
        }
        # menu.choices(:rename, "Rename to eliminate duplicates", "Rename element(s)") { @cli.say("Not supported yet") }
        menu.choice(:skip, help: "Don't change the elements", text: "Skip") { @cli.say("Skipping") }
        menu.select_by = :index_or_name
        menu.help("Help", "don't panic")
      end
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
      @cli = HighLine.new
      @doc = Document.read(archi_file)
      dupes = get_dupe_list
      if dupes.empty?
        puts "No potential duplicates detected"
        return
      end

      # TODO: sort keys by layer, then alphabetical, then connections
      dupes.keys.each do |element_type|
        dupes[element_type].keys.sort.each do |name|
          handle_duplicate(element_type, name, dupes[element_type][name])
        end
      end

      # TODO: use a destination filename for this method
      @doc.save_as("deduped.xml")
    end
  end
end
