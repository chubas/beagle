require 'rubygems'
require 'variable'
require 'rgl/adjacency'
require 'rgl/dot'
require 'rgl/topsort'

module Beagle
  class Machine

    attr_accessor :rules, :rule_list

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
          :skirt  => { :frequency => 30, :conditions => { sex => :male } }
      )

      @rules = build_graph([nose, hair, sex, bottom])

      @rule_list = {
          nose   => nil,
          hair   => nil,
          sex    => nil,
          bottom => nil
      }

      @rules.write_to_graphic_file('jpg')

    end

    def run!
      @current_generation = {}
      @rules.topsort_iterator.each do |rule|
        puts rule.name
        next if rule.root?

        result = @rule_list[rule] = rule.calculate_next_generation!(@rule_list)
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