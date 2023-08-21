module Fun
  def self.eq?(a, b)
    a == b
  end

  def self.ne?(a, b)
    a != b
  end

  def self.gt?(a, b)
    a > b
  end

  def self.ge?(a, b)
    a >= b
  end

  def self.lt?(a, b)
    a < b
  end

  def self.le?(a, b)
    a <= b
  end

  def self.id t
    t
  end

  def self.const(a, _)
    a
  end

  def self.pipe(arg, *fns)
    fns.reduce(arg) { |acc, fn| fn.(acc) }
  end

  def self.compose(arg, *fns)
    fns.reverse.reduce(arg) { |acc, fn| fn.(acc) }
  end

  def self.not?(fn, *args)
    !fn.(*args)
  end

  def self.nil_or(value, fallback)
    if value.nil?
      fallback
    else
      value
    end
  end

  def self.nil_or_else(value, &get_fallback)
    if value.nil?
      get_fallback.()
    else
      value
    end
  end

  def self.not_nil_or(value, fallback)
    if !value.nil?
      fallback
    else
      value
    end
  end

  def self.not_nil_or_else(value, &get_fallback)
    if !value.nil?
      get_fallback.()
    else
      value
    end
  end

  def self.not_nil_map(value, &mapper)
    if value.nil?
      value
    else
      mapper.(value)
    end
  end
end
