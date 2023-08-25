require 'lib/special'

PH = Special::PH

module CurryFun
  def self.eq?(t, u = PH)
    if u == PH
      ->(u) { eq? t, u }
    else
      t == u
    end
  end

  def self.ne?(t, u = PH)
    if u == PH
      ->(u) { ne? t, u }
    else
      t != u
    end
  end

  def self.gt?(t, u = PH)
    if u == PH
      ->(u) { gt? t, u }
    elsif t.respond_to? :>
      t > u
    else
      (t <=> u) == 1
    end
  end

  def self.ge?(t, u = PH)
    if u == PH
      ->(u) { ge? t, u }
    elsif t.respond_to? :>=
      t >= u
    else
      (t <=> u) >= 0
    end
  end

  def self.lt?(t, u = PH)
    if u == PH
      ->(u) { lt? t, u }
    elsif t.respond_to? :<
      t < u
    else
      (t <=> u) == -1
    end
  end

  def self.le?(t, u = PH)
    if u == PH
      ->(u) { le? t, u }
    elsif t.respond_to? :<=
      t <= u
    else
      (t <=> u) <= 0
    end
  end

  def self.const(a, _ = PH)
    if _ == PH
      ->(_) { a }
    else
      a
    end
  end

  def self.pipe *fns
    ->(arg) { fns.reduce arg { |acc, fn| fn.(acc) } }
  end

  def self.compose *fns
    ->(arg) {fns.reverse.reduce arg {|acc, fn| fn.(acc)}}
  end

  def self.not? fn
    ->(*args, **kwargs){!fn.(*args, **kwargs)}
  end

  def self.nil_or fallback, value=PH
    if value == PH
      ->(value){nil_or fallback, value}
    else
      value.nil? ? fallback : value
    end
  end

  def self.nil_or_else get_fallback, value=PH
    if value == PH
      ->(value){nil_or_else get_fallback, value}
    else
      value.nil? ? get_fallback.() : value
    end
  end

  def self.not_nil_or fallback, value=PH
    if value == PH
      ->(value){not_nil_or fallback, value}
    else
      value.nil? ? fallback : value
    end
  end

  def self.not_nil_or_else get_fallback, value=PH
    if value == PH
      ->(value) {not_nil_or_else get_fallback, value}
    else
      value.nil? ? get_fallback.() : value
    end
  end

  def self.not_nil_map mapper, value=PH
    if value==PH
      ->(value) {not_nil_map mapper, value}
    else
      value.nil? ? value : mapper.(value)
    end
  end

  def self.add a, b=PH
    if b == PH
      ->(b){add a, b}
    else
      a + b
    end
  end

  def self.minus a, b=PH
    if b == PH
      ->(b) {minus a, b}
    else
      a - b
    end
  end

  def self.mul a, b=PH
    if b == PH
      ->(b){mul a, b}
    else
      a * b
    end
  end

  def self.div a, b=PH
    if b == PH
      ->(b){div a, b}
    else
      a / b
    end
  end

  
end