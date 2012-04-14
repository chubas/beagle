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

    def calculate_next_generation!(previous_results)
      candidates = rules.select do |name, rules|
        if rules[:conditions]
          rules[:conditions].all? do |cond_rule, expected_result|
            previous_results[cond_rule] == expected_result
          end
        else
          true
        end
      end

      puts "Candidates: #{candidates.inspect}"

      previous_results[self] = candidates.choice[0]
      puts "Winner is #{previous_results[self]}"
    end

  end
end
