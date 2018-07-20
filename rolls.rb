
class Die
  @@seed = 0
  def self.seed; @@seed end
  def self.seed=(s) @@seed = s end
  
  attr_reader :seed, :sides, :generator
  def initialise(sides)
    @sides = sides
    @seed = @@seed
    @generator = nil
  end

  def roll(n=1)
    raise unless n.is_a? Integer
    raise if n < 1

    @generator, @seed = [nil, @@seed] if @seed != @@seed
    @generator ||= Random.new(@@seed)

    case
    when n > 1 then n.times.map { @generator.rand(1..@sides) }.sort.reverse
    when n == 1 then @generator.rand(1..@sides)
    else raise
    end
  end
end

d4, d6, d8, d10, d12, d20, d100 = [4, 6, 8, 10, 12, 20, 100].map(&Die.method(:new))

