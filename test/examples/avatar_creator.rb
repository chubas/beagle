require File.join(File.dirname(__FILE__), '../test_helper')

def generate_sample_run!

  # Debug method
  def ___puts_results(results)
    puts " ==="
    results.each do |variable, result|
      puts "   --- #{variable.name.to_s.rjust(7)} : #{result}"
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
    puts "Variance is #{machine.variance_for_generation(generation)}"
    results = machine.run(9, generation, current_gen)
    current_gen = results.choice
    results.each do |result|
      ___puts_results(result)
    end
    puts "~~~~~~~~~"
    puts "Random pick from generation is:"
    ___puts_results(current_gen)
    puts "~~~~~~~~~"
  end
end