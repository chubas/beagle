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
                              :small  => 25,
                              :normal => 50,
                              :big    => 25
  )

  hair = Beagle::Variable.new(:hair,
                              :black => 30,
                              :brown => 40,
                              :blond => 30
  )

  sex = Beagle::Variable.new(:sex,
                             :male   => 50,
                             :female => 50
  )

  bottom = Beagle::Variable.new(:bottom,
                                :jeans  => 40,
                                :shorts => 30,
                                :skirt  => { :weight => 30, :conditions => { sex => :female } }
  )

  glasses = Beagle::Variable.new(:glasses,
                                 :none => 60,
                                 :sun  => { :weight     => 40,
                                            :conditions => proc { |results| results[bottom] == :shorts || results[nose] == :normal || results[nose] == :big }, # Weird rules
                                            :depends_on => [bottom, nose]
                                 }
  )

  glasses_color = Beagle::Variable.new(:g_color,
                                        {
                                          :black => 60,
                                          :brown => 40,
                                          :red   => 20,
                                          :white => 20
                                        },
                                        :only_if => proc { |results| results[glasses] == :sun },
                                        :depends_on => [glasses]
  )

  rules = [nose, hair, sex, bottom, glasses, glasses_color]

  machine = Beagle::Machine.new(rules)

  current_gen = { }
  0.upto(10) do |generation|
    puts "Generation #{generation}"
    puts "Variance is #{machine.variance_for_generation(generation)}"
    results     = machine.run(9, generation, current_gen)
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