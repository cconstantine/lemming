require 'set'

class Result < Set
  def avg
    sum / size
  end

  def sum
    inject(0) do |sum, x|
      sum += x["dt"]
    end
  end

  def tp(n)
    times = map {|x| x["dt"]}.sort
    idx = ((times.length - 1) * n / 100.0).floor
    times[idx]
  end
end

class ResultSet
  attr_accessor :results
  def initialize
    self.results = Hash.new{ Result.new }
  end

  def add(hash)
    results[hash["name"]] = results[hash["name"]] << hash
  end

  def report
    results.each do |name, result|
      puts "#{result.count} #{name}: #{result.avg}, #{result.tp(99.9)}"
    end.count
  end
end