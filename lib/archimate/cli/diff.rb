module Archimate
  module Cli
    class Diff
      def self.diff(local, remote)
        my_diff = Diff.new
        my_diff.diff(local, remote)
      end

      # Going to treat remote as gospel and add in diffs from local

      # A context sensive 3-way merge is what I want for this customized so that it
      # intelligently works for archi files.

      # Caveat - I don't like folders under model layers - so I'll not bother trying to make those work

      # Should translate to work with meff files with minor changes

      # Should also facilitate a merge of two models with no common base - though more work

      # The entities that I care about are:
      # * Model (really only care about name, purpose/documentation, properties)
      # * Model Entities
      # * Connectors (Junction variations) - same as model entities AFAIK
      # * Relations
      # * Diagrams
      # * Organization (Folders)

      # New node (id not in original doc)
      # Node renamed (id matches, type is same, name changes) -> rename (see warn level based on use of node)
      # Node id conflict (id matches, type is diff) -> re-id node and otherwise treat as add (see id re-mapping section)
      # Node content differs
      #   - @name
      #   - documentation
      #   - property
      def diff(local_file, remote_file)
        remote = Nokogiri::XML(File.open(remote_file))
        local = Nokogiri::XML(File.open(local_file))

        local.xpath("//element").each do |local_node|
          remote_node = remote.at_css("[id='#{local_node['id']}']")
          # puts "#{local_node} not in remote" if remote_node.nil?
          if remote_node.nil?
            add_node_to_doc(local_node, remote)
          else
            local_el = Archimate::Diff::Element.new(local_node)
            remote_el = Archimate::Diff::Element.new(remote_node)
            if local_el != remote_el
              puts "Elements differ:\nlocal: #{local_node}\nremote: #{remote_node}\n\n"
            end
          end
        end

        File.open("tmp/MERGED.archimate", "w") do |f|
          f.write(remote)
        end
        []
      end
    end
  end
end
