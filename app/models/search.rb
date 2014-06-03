=begin rdoc
=Description
Name Space that contains the classes and modules used to build search quries. Its primary usage is done though
the Query class. The query class builds sql condition arrays for active record finds.
=Usage
Usage typically consists of a combination of active records with scope or find and initialize
and conditions.  Here is an example of using it with a find and a with scope
  Patient.find(:all, :conditions => Search::Query.new("search_string").conditions) # => Uses find and a simple search string

  # This wraps the search conditions with an ORDER BY statement
  Patient.with_scope(:find => {:order => "patients.modified_date DESC"}) do
    find(:all, :conditions => Search::Query.new(search_string).conditions(:exam_description => lambda { query.term_to_name_string(:exam_description) }) )
  end
=end
module Search

  class Query
    attr_accessor :search_string, :terms, :operator

    # Initializes the Query class with a search term that can be a string or a Hash containing field value pairs
    def initialize(string_or_hash)
      if string_or_hash.class == String
        self.search_string = string_or_hash.strip
        self.operator = "OR"
      elsif string_or_hash.class == Hash
        self.terms = string_or_hash.keys.inject({}) {|hash,key| hash[key] = string_or_hash[key].strip; hash }
        self.operator = "AND"
      end
    end

    # Takes the search term and builds additional terms based on number rules.
    # Currently this is only removing leading zeros and then ensuring that the list
    # of search terms returned contains unique entries
    def term_to_number(term)
      self.search_string ? sstring = self.search_string : sstring = terms[term]
      if not sstring.blank?
        mrns = []
        mrns << sstring.gsub(/^0+/,"") unless sstring.match(/^0+$/)
        mrns << sstring
        mrns.uniq
      else
        []
      end
    end

    # Takes the search term and builds additional terms based on name rules.
    # Currently these rules build permutations of the name spliting on the space
    # character, the carrot (^), and the comma (,).  It creates a list of all these
    # permutations using the +Search::Helpers.permutations+ method.
    def term_to_name_string(term)
      self.search_string ? sstring = self.search_string : sstring = terms[term]
      if not sstring.blank?
        names = Search::Helpers.permutations(sstring)
        names.uniq
      else
        []
      end
    end

    # Builds an array that can be passed to active record for sanitation, e.g., ["sql_field = ?","subsitution value"]
    def conditions(method_mapping=nil)
      unless method_mapping
        method_mapping = {
          #"patient_rsna_ids.rsna_id" => lambda { term_to_number(:rsna_id) },
          "patients.mrn" => lambda { term_to_number(:mrn) },
          "patients.patient_name" => lambda { term_to_name_string(:patient_name) }
        }
      end
      condition_lists = method_mapping.keys.collect {|field| field_concatinator(field, method_mapping[field].call()) }
      condition_lists = condition_lists.delete_if {|cl| cl.size == 0 }
      condition_lists.inject([]) do |master_list, conditions_list|
        if not master_list[0].blank?
          master_list[0] = master_list[0] + " #{self.operator} " + conditions_list[0]
        else
          master_list[0] = conditions_list[0]
        end
        master_list << conditions_list[1..conditions_list.size]
        master_list.flatten
      end
    end


    protected
    # Concatinates a fields given value(s) into an sql statement seperated by the "OR" keyword
    def field_concatinator(field, values)
      if values.size > 0
        list = [(["#{field} ~* ?"]*values.size).join(" OR ")] + values
        list[0] = "(#{list[0]})"
        list
      else
        []
      end
    end

  end

  module Helpers

    StringPermutationExp = /, +|[,\^ ]/
    PostgresPermutationExp = "[,\\^ ]+" #"(, +)|[,\\^ ]" this would have to match two characters between the words

    # Builds permutations of a string based on a default (StringPermutationExp) or specified permutation pattern (RegExp)
    # substituting the permutation points with a default (PostgresPermutationExp) or specified Postgresql RegExp.
    # Using the default expressions the following results would be produced:
    #   permutations("john doe") # => ["john(, +)|[,\\^ ]doe", "doe(, +)|[,\\^ ]john"]
    #   permutations("1, 2, 3") # => ["1(, +)|[,\\^ ]2(, +)|[,\\^ ]3", "1(, +)|[,\\^ ]3(, +)|[,\\^ ]2", "2(, +)|[,\\^ ]1(, +)|[,\\^ ]3", "2(, +)|[,\\^ ]3(, +)|[,\\^ ]1", "3(, +)|[,\\^ ]1(, +)|[,\\^ ]2", "3(, +)|[,\\^ ]2(, +)|[,\\^ ]1"]
    def self.permutations(string, options={})
      options.reverse_merge!({pattern: StringPermutationExp, db_exp: PostgresPermutationExp, assume_last_name_first: EdgeConfiguration.assume_last_name_first})
      items = string.split(options[:pattern])
      if options[:assume_last_name_first]
        ["^" + items.join(options[:db_exp])]
      else
        permutate(items).collect do |permutation|
          permutation.join(options[:db_exp])
        end
      end
    end

    # Recursive method that builds the permutations given a head, tail, and accumulator
    def self.permutate(tail,head=[],accum=[])
      if tail.size <= 1
        accum << head + tail
      else
        tail.collect do |tail_item|
          t = tail.clone
          t.delete(tail_item)
          permutate(t,head + [tail_item], accum)
        end
      end
      accum
    end

    # Simple string replace using the default or specified matching pattern (RegExp)
    # replaced with a default or specified Postgresql RegExp
    def self.flexibly_segregate(string, options={})
      options.reverse_merge!({:pattern => StringPermutationExp, :db_exp => PostgresPermutationExp})
      string.gsub(pattern,db_regexp)
    end

  end
end
