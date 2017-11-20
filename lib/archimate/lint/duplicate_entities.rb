# frozen_string_literal: true

module Archimate
  module Lint
    STOP_WORDS = %w[
      a able about above according accordingly across actually after afterwards again against all allow allows
      almost alone along already also although always am among amongst amoungst amount an and another any anybody
      anyhow anyone anything anyway anyways anywhere apart appear appreciate appropriate are around as aside ask
      asking associated at available away awfully be became because become becomes becoming been before
      beforehand behind being believe below beside besides best better between beyond bill both bottom brief but
      by call came can can't cannot cant cause causes certain certainly changes clearly co com come comes computer
      con concerning consequently consider considering contain containing contains corresponding could couldn't
      couldnt course cry currently de dear definitely describe described despite detail did didn't different do
      does doesn't doing don't done down downwards due during each edu eg eight either eleven else elsewhere empty
      enough entirely especially et etc even ever every everybody everyone everything everywhere ex exactly example
      except far few fifteen fifth fify fill find fire first five followed following follows for former formerly
      forth forty found four from full further furthermore get gets getting give given gives go goes going
      gone got gotten greetings had hadn't happens hardly has hasn't hasnt have haven't having he he's hello help
      hence her here here's hereafter hereby herein hereupon hers herself hi him himself his hither hopefully how
      howbeit however hundred i i'd i'll i'm i've ie if ignored immediate in inasmuch inc indeed indicate indicated
      indicates inner insofar instead interest into inward is isn't it it'd it'll it's its itself just keep keeps
      kept know known knows last lately later latter latterly least less lest let let's like liked likely little
      look looking looks ltd made mainly many may maybe me mean meanwhile merely might mill mine more moreover most
      mostly move much must my myself name namely nd near nearly necessary need needs neither never nevertheless
      new next nine no nobody non none noone nor normally not nothing novel now nowhere obviously of off often oh
      ok okay old on once one ones only onto or other others otherwise ought our ours ourselves out outside over
      overall own part particular particularly per perhaps placed please plus possible presumably probably provides
      put que quite qv rather rd re really reasonably regarding regardless regards relatively respectively right
      said same saw say saying says second secondly see seeing seem seemed seeming seems seen self selves sensible
      sent serious seriously seven several shall she should shouldn't show side since sincere six sixty so some
      somebody somehow someone something sometime sometimes somewhat somewhere soon sorry specified specify
      specifying still sub such sup sure system take taken tell ten tends th than thank thanks thanx that that's
      thats the their theirs them themselves then thence there there's thereafter thereby therefore therein theres
      thereupon these they they'd they'll they're they've thick thin think third this thorough thoroughly those
      though three through throughout thru thus tis to together too took top toward towards tried tries truly try
      trying twas twelve twenty twice two un under unfortunately unless unlikely until unto up upon us use used
      useful uses using usually value various very via viz vs want wants was wasn't way we we'd we'll we're we've
      welcome well went were weren't what what's whatever when whence whenever where where's whereafter whereas
      whereby wherein whereupon wherever whether which while whither who who's whoever whole whom whose why will
      willing wish with within without won't wonder would wouldn't yes yet you you'd you'll you're you've your
      yours yourself yourselves zero
    ].freeze

    class DuplicateEntities
      attr_reader :word_count
      # TODO: Add option to permit additional project specific stop words
      # TODO: Do relationships after elements are merged
      def initialize(model)
        @model = model
        @dupes = nil
        @count = nil
        @word_count = {}
        @ignored_entity_types = %w[Junction AndJunction OrJunction]
        dupe_list
      end

      def count
        @dupes.reduce(0) { |total, (_tag, ary)| total + ary.size }
      end

      def empty?
        count.zero?
      end

      def each
        @dupes.keys.sort.each do |name|
          ary = @dupes[name]
          element_type = ary.first.type
          yield(element_type, name, ary)
        end
      end

      protected

      def candidate_entities
        @model.entities.select do |entity|
          (entity.is_a?(DataModel::Element) || entity.is_a?(DataModel::Relationship)) &&
            !@ignored_entity_types.include?(entity.type)
        end
      end

      def dupe_list
        @dupes = candidate_entities.each_with_object({}) do |entity, hash|
          tag = entity_hash_name(entity)
          hash[tag] = hash.fetch(tag, []) << entity
        end
        @dupes.delete_if { |_tag, entities| entities.size <= 1 }
        # @word_count.sort_by(&:last).reverse.each { |ak, av| puts "#{ak}: #{av}" }
        @dupes
      end

      def entity_hash_name(entity)
        layer = entity.respond_to?(:layer) ? entity.layer : nil
        layer ||= DataModel::Layers::None
        layer_sort_order = DataModel::Layers.find_index(layer) # layer ? DataModel::Layers.find_index(layer) : 9
        [
          entity.class.name, # Taking advantage of Element being before Relationship
          layer_sort_order.to_s,
          entity.type,
          simplify(entity)
        ].join("/")
      end

      # This method takes an entity name and simplifies it for duplicate determination
      # This might be configurable in the future
      # 1. names are explicitly identical
      # 2. names differ only in case
      # 3. names differ only in whitespace
      # 4. names differ only in punctuation
      # 5. names differ only by stop-words (list of words such as "the", "api", etc.)
      def simplify(entity)
        name = entity.name&.dup.to_s || ""
        name = name.sub("(copy)", "") # (copy) is a special case inserted by the Archi tool
        name.downcase!
        name.gsub!(/[[:punct:]]/, "") unless entity.is_a?(DataModel::Relationship)
        name.strip!
        words = name.split(/\s/)
        words.each { |word| @word_count[word] = @word_count.fetch(word, 0) + 1 }
        name = words.reject { |word| STOP_WORDS.include?(word) }.join("")
        name.delete!(" \t\n\r")
        name = "#{name}:#{entity.source}:#{entity.target}" if entity.is_a?(DataModel::Relationship)
        name
      end
    end
  end
end
