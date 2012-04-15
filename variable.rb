module Beagle
  class Variable

    attr_accessor :rules, :name

    def initialize(name, rules = {})
      @name  = name
      @rules = rules
    end

    def root?
      @name == :root
    end

    def to_s
      @name
    end
    alias inspect to_s

    def calculate_next_generation!(previous_results, variance)
      if rand < variance || !previous_results[self] || preconditions_changed?(previous_results)
        candidates = @rules.select do |name, rules|
          if rules[:conditions]
            rules[:conditions].all? do |cond_rule, expected_result|
              previous_results[cond_rule] == expected_result
            end
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
      conditions && conditions.any? do |cond_rule, expected_result|
        previous_results[cond_rule] != expected_result
      end
    end

    def pick_weighted_choice(candidates)
      total_weight = candidates.inject(0){ |total, c| total + c[1][:frequency] }
      point = rand(total_weight)

      candidates.each do |name, options|
        weight = options[:frequency]
        return name if weight >= point
        point -= weight
      end
    end

  end
end
