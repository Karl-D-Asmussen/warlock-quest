
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

  def to_int; roll end
  def +(b) roll + b.to_int end
  def -(b) roll - b.to_int end
end

class Array; def tros; sort { |a, b| b <=> a } end; end

Dice = [4,6,8,10,12,20,100].map { |n| [ n, Die.new(n)] }.to_h.freeze

def   d4(n=nil); if n.nil? then Dice[4]   else Dice[4].roll(n)   end end
def   d6(n=nil); if n.nil? then Dice[6]   else Dice[6].roll(n)   end end
def   d8(n=nil); if n.nil? then Dice[8]   else Dice[8].roll(n)   end end
def  d10(n=nil); if n.nil? then Dice[10]  else Dice[10].roll(n)  end end
def  d12(n=nil); if n.nil? then Dice[12]  else Dice[12].roll(n)  end end
def  d20(n=nil); if n.nil? then Dice[20]  else Dice[20].roll(n)  end end
def d100(n=nil); if n.nil? then Dice[100] else Dice[100].roll(n) end end
