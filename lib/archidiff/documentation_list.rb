module Archidiff
  class DocumentationList
    attr_reader :doc_list

    def initialize(node_set)
      @doc_list = node_set.each_with_object([]) { |i, a| a << i.text.strip unless i.text.strip.empty? }
    end

    def ==(other)
      return false unless other.is_a?(DocumentationList)
      @doc_list.each_with_index { |d, i| return false unless d == other.doc_list[i] }
      true
    end

    def size
      @doc_list.size
    end

    def diff(other)
      raise ArgumentError, "Expected DocumentationList" unless other.is_a?(DocumentationList)
      changes = doc_list.each_with_object([]) do |i, a|
        a << Change.new(:delete, i) unless other.doc_list.include?(i)
      end
      other.doc_list.each_with_object(changes) do |i, a|
        a << Change.new(:insert, i) unless doc_list.include?(i)
      end
    end
  end
end
