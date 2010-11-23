module Search
  class Query
    attr_accessor :search_string, :terms, :operator
    def initialize(string_or_hash)
      if string_or_hash.class == String
        self.search_string = string_or_hash.strip
        self.operator = "OR"
      elsif string_or_hash.class == Hash
        self.terms = string_or_hash.keys.inject({}) {|hash,key| hash[key] = string_or_hash[key].strip; hash }
        self.operator = "AND"
      end
    end

    def term_to_number(term)
      self.search_string ? sstring = self.search_string : sstring = terms[term]
      if not sstring.blank?
        mrns = []
        mrns << sstring.gsub(/^0+/,"")
        mrns << sstring
        mrns.uniq
      else
        []
      end
    end

    def term_to_name_string(term)
      self.search_string ? sstring = self.search_string : sstring = terms[term]
      if not sstring.blank?
        names = []
        names << sstring
        names = names + Search::Helpers.permutations(sstring)
        names.uniq
      else
        []
      end
    end

    def conditions(method_mapping=nil)
      unless method_mapping
        method_mapping = {
          "patient_rsna_ids.rsna_id" => lambda { term_to_number(:rsna_id) },
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
    PostgresPermutationExp = "(, +)|[,\\^ ]"

    def self.permutations(string, options={})
      options.reverse_merge!({:pattern => StringPermutationExp, :db_exp => PostgresPermutationExp})
      items = string.split(options[:pattern])
      permutate(items).collect do |permutation|
        permutation.join(options[:db_exp])
      end
    end

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

    def self.flexibly_segregate(string, options={})
      options.reverse_merge!({:pattern => StringPermutationExp, :db_exp => PostgresPermutationExp})
      string.gsub(pattern,db_regexp)
    end

  end
end
