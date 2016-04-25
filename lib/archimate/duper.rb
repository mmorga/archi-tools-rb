require "nokogiri"

module Archimate
  class Duper
    XSI = "http://www.w3.org/2001/XMLSchema-instance".freeze

    def element_type(el)
      el.attribute_with_ns("type", XSI).value[10..-1]
    end

    def list_dupes(archi_file)
      doc = Nokogiri::XML(File.open(archi_file))
      doc.css('*').each do |node|
        puts node.name
      end
    end
  end
end
