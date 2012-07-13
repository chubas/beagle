module Beagle
  class Variable

    attr_accessor :rules, :name
    attr_reader :dependencies

    def initialize(name, rules = {}, variable_options = {})
      @name  = name
      @rules = normalize_rules(rules)
      @variable_options = variable_options
      @dependencies = get_dependencies
      normalize_conditions!
    end

    def normalize_rules(rules)
      rules.update(rules) do |_, value|
        if value.is_a?(Numeric)
          { :weight => value }
        else
          value
        end
      end
    end

    def normalize_conditions!
      @rules.each do |_, rules|
        if rules[:conditions] && rules[:conditions].is_a?(Hash)
          hashed_conditions = rules[:conditions]
          rules[:conditions] = Proc.new do |current_results|
            hashed_conditions.all?{ |rule, expected| current_results[rule] == expected }
          end
        end
      end
    end

    def get_dependencies
      dependencies = []
      dependencies += @variable_options[:depends_on].to_a
      @rules.each do |_, rule|
        if rule[:depends_on]
          dependencies += rule[:depends_on]
        elsif rule[:conditions]
          dependencies += rule[:conditions].keys
        end
      end
      dependencies.flatten.compact.uniq
    end

    def root?
      @name == :root
    end

    def to_s
      @name
    end
    alias inspect to_s

    def calculate_next_generation!(previous_results, variance)
      if @variable_options[:only_if] && !@variable_options[:only_if].call(previous_results)
        return nil
      end
      if rand < variance || !previous_results[self] || preconditions_changed?(previous_results)
        candidates = @rules.select do |_, rules|
          if rules[:conditions]
            rules[:conditions].call(previous_results)
            #rules[:conditions].all? do |cond_rule, expected_result|
            #  previous_results[cond_rule] == expected_result
            #end
          else
            true
          end
        end

        pick_weighted_choice(candidates)
      else
        previous_results[self]
      end
    end

    def preconditions_changed?(previous_results)
      conditions = rules[previous_results[self]][:conditions]
      conditions && !conditions.call(previous_results)
    end

    def pick_weighted_choice(candidates)
      total_weight = candidates.inject(0){ |total, c| total + c[1][:weight] }
      point = rand(total_weight)

      candidates.each do |name, options|
        weight = options[:weight]
        return name if weight >= point
        point -= weight
      end
    end

  end
end
