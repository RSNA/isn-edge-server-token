module Search
  class Query
    attr_accessor :search_string
    def initialize(search_string)
      self.search_string = search_string.strip
    end

    def to_mrn_terms
      mrns = []
      mrns << self.search_string.gsub(/^0+/,"") 
      mrns << self.search_string
      mrns.uniq
    end

    def to_rsna_id_terms
      to_mrn_terms
    end

    def to_name_terms
      names = []
      names << self.search_string
      names = names + Search::Helpers.permutations(search_string)
      names.uniq
    end

    def conditions(method_mapping={})
      method_mapping.reverse_merge!({
                                      "patient_rsna_ids.rsna_id" => :to_rsna_id_terms,
                                      "patients.mrn" => :to_mrn_terms,
                                      "patients.patient_name" => :to_name_terms
                                    })
      condition_lists = method_mapping.keys.collect {|field| field_concatinator(field, self.send(method_mapping[field])) }
      condition_lists.inject([]) do |master_list, conditions_list|
        if not master_list[0].blank?
          master_list[0] = master_list[0] + " OR " + conditions_list[0]
        else
          master_list[0] = conditions_list[0]
        end
        master_list << conditions_list[1..conditions_list.size]
        master_list.flatten
      end
    end


    protected
    def field_concatinator(field, values)
      [(["#{field} ~* ?"]*values.size).join(" OR ")] + values
    end

    def permutate(string)
      
    end
  end

  module Helpers
    StringPermutationExp = /, +|[,\^ ]/
    PostgresPermutationExp = "(, +)|[,\\^ ]"
    def self.permutations(string, options={})
      options.reverse_merge!({:pattern => StringPermutationExp, :db_exp => PostgresPermutationExp})
      items = string.split(options[:pattern])
      puts items
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
