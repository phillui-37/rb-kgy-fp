# frozen_string_literal: true

require 'lib/special'

PH = Special::PH
OPT = Special::OPT

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

  def self.pipe(*fns)
    ->(arg) { fns.reduce(arg) { |acc, fn| fn.(acc) } }
  end

  def self.compose(*fns)
    ->(arg) { fns.reverse.reduce(arg) { |acc, fn| fn.(acc) } }
  end

  def self.not? & fn
    ->(*args, **kwargs) { !fn.(*args, **kwargs) }
  end

  def self.nil_or fallback, value = PH
    if value == PH
      ->(value) { nil_or fallback, value }
    else
      value.nil? ? fallback : value
    end
  end

  def self.nil_or_else get_fallback: OPT, value: PH, &blk
    if (!blk && get_fallback == OPT) || (blk && get_fallback.class == Proc)
      raise ArgumentError.new "Either get_fallback or blk must be provided"
    end
    _fn = blk || get_fallback
    if value == PH
      ->(value) { nil_or_else get_fallback: _fn, value: value }
    else
      value.nil? ? _fn.() : value
    end
  end

  def self.not_nil_or fallback, value = PH
    if value == PH
      ->(value) { not_nil_or fallback, value }
    else
      value.nil? ? value : fallback
    end
  end

  def self.not_nil_or_else get_fallback: OPT, value: PH, &blk
    if (!blk && get_fallback == OPT) || (blk && get_fallback.class == Proc)
      raise ArgumentError.new "Either get_fallback or blk must be provided"
    end
    _fn = blk || get_fallback
    if value == PH
      ->(value) { not_nil_or_else get_fallback: _fn, value: value }
    else
      value.nil? ? value : _fn.()
    end
  end

  def self.not_nil_map mapper: OPT, value: PH, &blk
    if (!blk && mapper == OPT) || (blk && (mapper.class == Proc || mapper.class == Symbol))
      raise ArgumentError.new "Either mapper or blk must be provided"
    end
    _fn = blk || (mapper.class == Proc ? mapper : ->(obj) { obj.method(mapper).() })
    if value == PH
      ->(value) { not_nil_map mapper: _fn, value: value }
    else
      value.nil? ? value : _fn.(value)
    end
  end

  def self.add a, b = PH
    if b == PH
      ->(b) { add a, b }
    else
      a + b
    end
  end

  def self.minus a, b = PH
    if b == PH
      ->(b) { minus a, b }
    else
      a - b
    end
  end

  def self.mul a, b = PH
    if b == PH
      ->(b) { mul a, b }
    else
      a * b
    end
  end

  def self.div a, b = PH
    if b == PH
      ->(b) { div a, b }
    else
      a / b
    end
  end

  def self.mod a, b = PH
    if b == PH
      ->(b) { mod a, b }
    else
      a % b
    end
  end

  def self.flip a, b = PH, &fn
    if b == PH && !fn
      ->(b = PH, &fn) { flip(a, b, &fn) }
    elsif b == PH && fn
      ->(b) { flip(a, b, &fn) }
    elsif b != PH && !fn
      ->(&fn) { flip(a, b, &fn) }
    else
      fn.(b, a)
    end
  end

  def self.all? fn: OPT, args: PH, &blk
    if (fn == OPT && !blk) || ((fn.class == Proc || fn.class == Symbol) && blk)
      raise ArgumentError.new("Either fn or blk must be provided")
    end
    _fn = blk || (fn.class == Proc ? fn : ->(obj) { obj.method(fn).() })
    if args == PH
      ->(*args) { all?(fn: _fn, args: args) }
    else
      args.reduce(true) { |result, arg| result && _fn.(arg) }
    end
  end

  def self.any? fn: OPT, args: PH, &blk
    if (fn == OPT && !blk) || ((fn.class == Proc || fn.class == Symbol) && blk)
      raise ArgumentError.new("Either fn or blk must be provided")
    end
    _fn = blk || (fn.class == Proc ? fn : ->(obj) { obj.method(fn).() })
    if args == PH
      ->(*args) { any?(fn: _fn, args: args) }
    else
      args.reduce(false) { |result, arg| result || _fn.(arg) }
    end
  end

  def self.and? a, b = PH
    if b == PH
      ->(b) { and?(a, b) }
    else
      a && b
    end
  end

  def self.or? a, b = PH
    if b == PH
      ->(b) { or?(a, b) }
    else
      a || b
    end
  end

  def self.xor? a, b = PH
    if b == PH
      ->(b) { xor? a, b }
    else
      (!a && b) || (a && !b)
    end
  end

  def self.clamp lower, upper = PH, value = PH
    if upper == PH
      ->(upper = PH, value = PH) { clamp lower, upper, value }
    elsif value == PH
      ->(value) { clamp lower, upper, value }
    else
      if lower > value
        lower
      elsif upper < value
        upper
      else
        value
      end
    end
  end

  def self.cond cond_mappers
    -> (*args, **kwargs) {
      return nil if args.length == 0 && kwargs.size == 0
      cond_mappers.each do |fns|
        fns => [cond, mapper]
        return mapper.(*args, **kwargs) if cond.(*args, **kwargs)
      end
      nil
    }
  end

  def self.desc(&comparator)
    -> (values) {
      if values.class == Hash
        Hash[values.sort_by { |k, v| comparator.(k, v) }.reverse]
      elsif values.class == Array
        values.sort_by { |v| comparator.(v) }.reverse
      end
    }
  end

  def self.asc(&comparator)
    -> (values) {
      if values.class == Hash
        Hash[values.sort_by { |k, v| comparator.(k, v) }]
      elsif values.class == Array
        values.sort_by { |v| comparator.(v) }
      end
    }
  end

  def self.diff obj1, obj2 = PH
    if obj2 == PH
      ->(obj2) { diff obj1, obj2 }
    else
      get_diff = ->(arr1, arr2) {
        arr1.size > arr2.size ? arr1 - arr2 : arr2 - arr1
      }
      if obj1.class != obj2.class
        raise ArgumentError.new "obj1 is not same type with obj2"
      elsif obj1.class == Hash
        diff = get_diff.(obj1.to_a, obj2.to_a)
        Hash[*diff.flatten]
      else
        get_diff.(obj1, obj2)
      end
    end
  end

  def self.intersect obj1, obj2 = PH
    if obj2 == PH
      ->(obj2) { intersect obj1, obj2 }
    else
      get_inte = ->(arr1, arr2) {
        arr1.size > arr2.size ? arr1 - (arr1 - arr2) : arr2 - (arr2 - arr1)
      }
      if obj1.class != obj2.class
        raise ArgumentError.new "obj1 is not same type with obj2"
      elsif obj1.class == Hash
        inte = get_inte.(obj1.to_a, obj2.to_a)
        Hash[*inte.flatten]
      else
        get_inte.(obj1, obj2)
      end
    end
  end

  def self.non_intersect obj1, obj2 = PH
    if obj2 == PH
      ->(obj2) { non_intersect obj1, obj2 }
    else
      if obj1.class != obj2.class
        raise ArgumentError.new "obj1 is not same type with obj2"
      elsif obj1.class == Hash
        left = obj1.to_a - obj2.to_a
        right = obj2.to_a - obj1.to_a
        Hash[*left.flatten, *right.flatten]
      else
        left = obj1 - obj2
        right = obj2 - obj1
        (left + right).uniq
      end
    end
  end

  def self.union obj1, obj2 = PH
    if obj2 == PH
      ->(obj2) { union obj1, obj2 }
    else
      if obj1.class != obj2.class
        raise ArgumentError.new "obj1 is not same type with obj2"
      elsif obj1.class == Hash
        obj1.merge(obj2)
      else
        (obj1 + obj2).uniq
      end
    end
  end
end