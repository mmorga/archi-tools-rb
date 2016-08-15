require "ox"
require "pp"

module Archimate
  module Conversion
    class ArchiToMeff < ::Ox::Sax
      attr_accessor :element_names, :element_sigs, :id_map, :doc


      def initialize(output_io)
        @line = 0
        @pos = 0
        @col = 0
        @doc = Ox::Builder.io(output_io, indent: 2, size: 1000)
        @doc.instruct("xml", version: '1.0', encoding: 'UTF-8')
        @id_map = {}
        @cur_path = []
        @cur_node = {
          name: "root",
          attrs: {},
          parent: "",
          children: []
        }
      end

      def start_element(name)
        @cur_node = {
          name: name,
          attrs: {},
          parent: @cur_path.last,
          children: []
        }
        @cur_path.push @cur_node
      end

      def end_element(_name)
        @id_map[@cur_node[:attrs][:id]] = @cur_node if @cur_node[:attrs].key?(:id)
        @cur_path.pop
        @cur_path.last[:children] << @cur_node unless @cur_path.empty?
      end

      def attr(name, str)
        @cur_node[:attrs][name] = str
      end

      def attrs_done
        case @cur_node[:name]
        when :"archimate:model"
          @doc.element(
            "model",
            "xmlns" => "http://www.opengroup.org/xsd/archimate",
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
            "identifier" => "id-#{@cur_node[:attrs][:id]}",
            "xsi:schemaLocation" =>
              "http://www.opengroup.org/xsd/archimate " \
              "http://www.opengroup.org/xsd/archimate/archimate_v2p1.xsd"
          )
          @doc.element("name", "xml:lang" => "en") { @doc.text @cur_node[:attrs][:name] }
        end
      end

      private

      def instruct(target)
      end

      def end_instruct(target)
      end

      # Equiv to attr but value is a castable Ox::Sax::Value
      def attr_value(name, value)
      end

      def doctype(str)
      end

      def comment(str)
      end

      def cdata(str)
      end

      def text(str)
      end

      # Equiv to text but value is a castable Ox::Sax::Value
      def value(value)
      end
    end
  end
end
