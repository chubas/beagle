module Beagle
  class Machine

    attr_accessor :variables

    def initialize(rules)
      @variables = build_graph(rules)
    end

    def run(number_of_samples, generation, starting_point)
      number_of_samples.times.map do
        new_result_set = starting_point.dup
        @variables.topsort_iterator.each do |variable|
          next if variable.root?

          new_result_set[variable] = variable.calculate_next_generation!(new_result_set, variance_for_generation(generation))
        end
        new_result_set
      end
    end

    def build_graph(rules)
      root = Beagle::Variable.new(:root)
      graph_edges = []
      rules.each do |rule|
          if rule.dependencies.empty?
            graph_edges << [root, rule]
          else
            rule.dependencies.each do |dependency|
              graph_edges << [dependency, rule]
            end
          end
      end

      RGL::DirectedAdjacencyGraph[*graph_edges.flatten]
    end

    def variance_for_generation(generation)
      Math::E ** -(0.2 * generation)
    end

  end

end
