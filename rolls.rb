
class Die
  @@seed = 0
  def self.seed; @@seed end
  def self.seed=(s) @@seed = s end
  
  attr_reader :seed, :sides, :generator
  def initialize(sides)
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
    when n > 1 then n.times.map { @generator.rand(1..@sides) }
    when n == 1 then @generator.rand(1..@sides)
    else raise
    end
  end

  def +(b) roll + b end
  def -(b) roll - b end
end

class Array; def tros; sort { |a, b| b <=> a } end; end

Dice = [4,6,8,10,12,20,100].map { |n| [ n, Die.new n ] }.to_h.freeze

def d4; Dice[4] end
def d6; Dice[6] end
def d8; Dice[8] end
def d10; Dice[10] end
def d12; Dice[12] end
def d20; Dice[20] end
def d100; Dice[100] end
