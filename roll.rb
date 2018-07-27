#!/usr/bin/ruby2.5

class Roller
  MAGIC = /^(?<b>[+-]\d+)|(?<n>[1-9]\d*)?d(?<d>(?:[1-9]\d+|[2-9]))(?:k(?<k>[1-9]\d*)t(?<t>[1-9]\d*)|t(?<t>[1-9]\d*)k(?<k>[1-9]\d*)|k(?<k>[1-9]\d*)|t(?<t>[1-9]\d*)|)$/o.freeze
  NUMERALS = '0123456789'.freeze
  SUBSCRIPTS = '₀₁₂₃₄₅₆₇₈₉'.freeze
  
  def self.main(argv)
    if argv.empty?
      loop do
        print "?? "
        expr = gets 
        break if expr.nil? or expr.empty?
        self.run(expr, true)
      end
    else
      self.run(argv.join(' '))
    end
  end

  def self.run(expr, strict=false)
    begin
      roller = self.new(expr, strict: strict)
      puts ">> #{roller.result} = #{roller.roll}"
      puts "// #{roller.discarded}" if roller.discarded?
      puts
    rescue
      puts "error"
    end
  end

  def initialize(expr=nil, strict: false, seed: nil)
    @keep = []
    @kill = []
    @toss = []
    @expr = []
    @strict = strict
    @generator = (seed ? Random.new(seed) : Random.new)
    self.evaluate(expr) if expr
  end

  def result
    @keep.map(&:first).sum
  end

  def expression
    sign, *rest = @expr.flatten
    sign = '' unless sign == '-'
    sign + rest.join(' ')
  end

  def roll
    sign, *rest = @keep.sort.reverse.map { |pair| render_roll(pair) }.flatten
    if @keep[0].first >= 0
      sign = ''
    end
    sign + rest.join(' ')
  end

  def discarded?
    !(@kill.empty? && @toss.empty?)
  end

  def discarded
    (@kill + @toss).sort.reverse.map { |pair| render_roll(pair).last }.join(' ')
  end
  
  def evaluate(expr)
    raise TypeError, "`#{expr}':#{expr.class} is not a String" unless expr.is_a? String

    expr.split(' ').each do |atom|
      ok = compute(atom)
      if @strict && !ok
        raise ArgumentError, "`#{atom}' is not a valid die roll or bonus expression in `#{expr}`"
      end
    end

    self
  end

  def render_roll(pair)
    r, d = pair
    if d
      ['+', r.to_s + d.to_s.tr(NUMERALS, SUBSCRIPTS)]
    else
      [r.negative? ? '-' : '+', r.abs.to_s]
    end
  end
  
  def compute(atom)
    return false unless MAGIC =~ atom

    if $~[:b]
      b = $~[:b].to_i
      roll = [[b, nil]]
      kill = []
      toss = []
      @expr << [b.negative? ? '-' : '+', b.abs.to_s]
    else
      n = ($~[:n] || 1).to_i
      k = ($~[:k] || 0).to_i
      t = ($~[:t] || 0).to_i
      d = $~[:d].to_i
      roll = n.times.map { [@generator.rand(1..d), d] }.sort.reverse

      @expr << ['+', "#{n if n!=1}d#{d}#{"k#{k}" if k!=0}#{"t#{t}" if t!=0}"]

      toss = roll.slice!(0...t)
      kill = (k!=0 ? roll.slice!(-k..-1) : [])
    end

    @keep.concat roll
    @kill.concat kill
    @toss.concat toss

    true
  end
end

if $0 == __FILE__
  trap :INT do exit 0 end
  Roller.main(ARGV.map(&:dup))
end
