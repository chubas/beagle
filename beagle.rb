require 'rubygems'
require 'variable'
require 'colorize'
require 'rgl/adjacency'
require 'rgl/dot'
require 'rgl/topsort'

module Beagle
  class Machine

    attr_accessor :variables

    def initialize(rules)
      @variables = build_graph(rules)
    end

    def run(samples, generation, starting_point)
      samples.times.map do

        new_result_set = starting_point.dup
        @variables.topsort_iterator.each do |variable|
          next if variable.root?

          new_result_set[variable] = variable.calculate_next_generation!(new_result_set, variance_for_generation(generation))
        end
        ___puts_results(new_result_set)
        new_result_set

      end
    end

    def ___puts_results(results)
      puts " ==="
      results.each do |variable, result|
        puts "   --- #{variable.name} : #{result}"
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


nose = Beagle::Variable.new(:nose,
    :small  => { :frequency => 25 },
    :normal => { :frequency => 50 },
    :big    => { :frequency => 25 }
)

hair = Beagle::Variable.new(:hair,
    :black  => { :frequency => 30 },
    :brown  => { :frequency => 40 },
    :blond  => { :frequency => 30 }
)

sex = Beagle::Variable.new(:sex,
    :male   => { :frequency => 50 },
    :female => { :frequency => 50 }
)

bottom = Beagle::Variable.new(:bottom,
    :jeans  => { :frequency => 40 },
    :shorts => { :frequency => 30 },
    :skirt  => { :frequency => 30,:conditions => { sex => :female } }
)

glasses = Beagle::Variable.new(:glasses,
    :none   => { :frequency => 60 },
    :sun    => { :frequency => 40,
                 :conditions => proc{ |results| results[bottom] == :shorts || results[nose] == :snormal || results[nose] == :big }, # Weird rules
                 :depends_on => [bottom, nose]
               }
)

rules = [nose, hair, sex, bottom, glasses]

machine = Beagle::Machine.new(rules)
current_gen = {}
0.upto(10) do |generation|
  puts "Generation #{generation}"
  results = machine.run(9, generation, current_gen)
  current_gen = results.choice
  puts "~~~~~~~~~"
  puts "Winner from generation is:"
  machine.___puts_results(current_gen)
  puts "~~~~~~~~~"
end