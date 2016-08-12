module Archimate
  class Convert
    include Archimate::ErrorHelper

    SUPPORTED_FORMATS = %w(meff2.1 archi nquads).freeze

    def convert(infile, to_format, output)
      return unless output
      doc = Document.read(infile)
      return if doc.nil?

      case to_format
      when "meff2.1"
        output.write(Archimate::Conversion.meff_from_archi(doc.doc).to_xml)
      when "nquads"
        output.write(Archimate::Quads.new.n_quads(doc))
      else
        error "Conversion to '#{to_format}' is not supported yet."
      end
    end
  end
end
