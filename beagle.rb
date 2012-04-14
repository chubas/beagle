require 'rubygems'
require 'variable'
require 'rgl/adjacency'
require 'rgl/dot'
require 'rgl/topsort'

module Beagle
  class Machine

    attr_accessor :variables, :generation_results

    def initialize
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
          :skirt  => { :frequency => 30, :conditions => { sex => :female } }
      )

      @variables = build_graph([nose, hair, sex, bottom])

      @generation_results = {
          nose   => nil,
          hair   => nil,
          sex    => nil,
          bottom => nil
      }

      @variables.write_to_graphic_file('jpg')
      @current_generation = 0

    end

    def run!
      @current_generation += 1
      @variables.topsort_iterator.each do |variable|
        puts "Evaluating #{variable.name}"
        next if variable.root?

        @generation_results[variable] = variable.calculate_next_generation!(@generation_results)

      end
      ___puts_generation
    end

    def ___puts_generation
      puts "GENERATION: #@current_generation"
      @generation_results.each do |variable, result|
        puts "   --- #{variable.name} : #{result}"
      end
    end

    def build_graph(variables)
      root = Beagle::Variable.new(:root)
      graph_edges = []
      variables.each do |var|
        var.rules.each do |name, rule|

          dependent = false
          if rule[:conditions]
            dependent = true
            rule[:conditions].each do |key, _|
              graph_edges <<[key, var]
            end
          end

          unless dependent
            graph_edges << [root, var]
          end
        end
      end

      RGL::DirectedAdjacencyGraph[*graph_edges.flatten]
    end

    def next_generation

    end

  end

end

machine = Beagle::Machine.new
machine.run!