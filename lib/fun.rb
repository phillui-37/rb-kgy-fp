module Fun
  def self.eq?(a, b)
    a == b
  end

  def self.ne?(a, b)
    a != b
  end

  def self.gt?(a, b)
    if a.respond_to?(:>)
      a > b
    else
      (a <=> b) == 1
    end
  end

  def self.ge?(a, b)
    if a.respond_to?(:>=)
      a >= b
    else
      (a <=> b) >= 0
    end
  end

  def self.lt?(a, b)
    if a.respond_to?(:<)
      a < b
    else
      (a <=> b) == -1
    end
  end

  def self.le?(a, b)
    if a.respond_to?(:<=)
      a <= b
    else
      (a <=> b) <= 0
    end
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

  def self.not?(fn, *args, **kwargs)
    !fn.(*args, **kwargs)
  end

  def self.nil_or(value, fallback)
    value.nil? ? fallback : value
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
    value.nil? ? value : mapper.(value)
  end

  def self.add(a, b)
    a + b
  end

  def self.minus(a, b)
    a - b
  end

  def self.mul(a, b)
    a * b
  end

  def self.div(a, b)
    a / b
  end

  def self.mod(a, b)
    a % b
  end

  def self.flip(b, a, &fn)
    fn.(a, b)
  end

  def self.all?(fst, *snd)
    if fst.class == Proc
      snd.all?(&fst)
    else
      snd.reduce(true) { |result, fn| result && fn.(fst) }
    end
  end

  def self.any?(fst, *snd)
    if fst.class == Proc
      snd.all?(&fst)
    else
      snd.reduce(false) { |result, fn| result || fn.(fst) }
    end
  end

  def self.clamp(lower, upper, value)
    if lower > value
      lower
    elsif upper < value
      upper
    else
      value
    end
  end

  def self.cond(cond_mappers, *args, **kwargs)
    return nil if args.length == 0 && kwargs.size == 0
    cond_mappers.each { |fns|
      fns => [cond, mapper]
      return mapper.(*args, **kwargs) if cond.(*args, **kwargs)
    }
    nil
  end

  def self.curry(&fn)
    require "special"

    req = 1 << 0
    opt = 1 << 1
    rest = 1 << 2
    kreq = 1 << 3
    kopt = 1 << 4
    krest = 1 << 5
    block = 1 << 6

    core = ->(this, fn, c_params = [], c_remain_param_count = 0) do
      ->(*args, **kwargs, &proc) do
        cp_c_params = Marshal.load(Marshal.dump(c_params)) # use serialization to ensure whole operation is pure
        cp_c_remain_param_count = c_remain_param_count
        arg_idx = 0
        _kwargs = { **kwargs }

        (0...cp_c_params.length).each { |i|
          param = cp_c_params[i]
          filled = param[:value] != Special::PH && param[:value] != Special::OPT

          if (param[:type] & (req | opt)) != 0 && !filled
            param[:value] = args[arg_idx]
            arg_idx += 1
            cp_c_remain_param_count -= 1 if param[:type] == req
          end

          if (param[:type] & (kreq | kopt) != 0) && !filled && _kwargs[param[:name]] != nil
            param[:value] = _kwargs.delete(param[:name])
            cp_c_remain_param_count -= 1 if param[:type] == kreq
          end

          if param[:type] == block && !filled && proc
            param[:value] = proc
            cp_c_remain_param_count -= 1
          end
        }

        if args.length >= arg_idx + 1 && cp_c_params.any? { |p| p[:type] == rest }
          cp_c_params.find { |p| p[:type] == rest }[:value] = args[arg_idx, args.length]
        end

        if _kwargs.length > 0 && cp_c_params.any? { |p| p[:type] == krest }
          cp_c_params.find { |p| p[:type] == krest }[:value] = _kwargs
        end

        if cp_c_remain_param_count == 0
          _params = []
          _kparams = {}
          _proc = nil
          cp_c_params.each do |param|
            case param[:type]
            when req, opt
              _params << param[:value] if param[:value] != Special::OPT && param[:value] != Special::PH
            when kreq, kopt
              _kparams[param[:name]] = param[:value] if param[:value] != Special::OPT && param[:value] != Special::PH
            when rest
              _params.push(*param[:value])
            when krest
              _kparams.update(param[:value])
            when proc
              _proc = param[:value]
            end
          end
          if _proc
            fn.(*_params, **_kparams, &_proc)
          else
            fn.(*_params, **_kparams)
          end
        else
          this.(this, fn, cp_c_params, cp_c_remain_param_count)
        end
      end
    end

    params = []
    remain_param_count = 0

    # check params
    fn.parameters.each do |detail|
      detail => [type, name]
      case type
      when :req
        params << { name: name, value: Special::PH, type: req }
        remain_param_count += 1
      when :opt
        params << { name: name, value: Special::OPT, type: opt }
      when :rest
        params << { name: name, type: rest }
      when :keyreq
        params << { name: name, value: Special::PH, type: kreq }
        remain_param_count += 1
      when :key
        params << { name: name, value: Special::OPT, type: kopt }
      when :keyrest
        params << { name: name, type: krest }
      when :block
        params << { name: name, value: Special::PH, type: block }
        remain_param_count += 1
      end
    end

    core.(core, fn, params, remain_param_count)
  end

  def self.dec n
    n - 1
  end

  def self.inc n
    n + 1
  end

  def self.desc(values, &comparator)
    if values.class == Hash
      Hash[values.sort_by { |k, v| comparator.(k, v) }.reverse]
    elsif values.class == Array
      values.sort_by { |v| comparator.(v) }.reverse
    end
  end

  def self.asc(values, &comparator)
    if values.class == Hash
      Hash[values.sort_by { |k, v| comparator.(k, v) }]
    elsif values.class == Array
      values.sort_by { |v| comparator.(v) }
    end
  end

  def self.to_sym s
    s.to_sym
  end

  def self.diff(obj1, obj2)
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

  def self.intersect(obj1, obj2)
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

  def self.non_intersect(obj1, obj2)
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

  def self.union(obj1, obj2)
    if obj1.class != obj2.class
      raise ArgumentError.new "obj1 is not same type with obj2"
    elsif obj1.class == Hash
      obj1.merge(obj2)
    else
      (obj1 + obj2).uniq
    end
  end

  def self.empty obj
    case obj.class.to_s
    when 'Hash'
      {}
    when 'Array'
      []
    when 'String'
      ''
    else
      nil
    end
  end

  def self.mean * ns
    ns.reduce(:+) / ns.length
  end

  def self.median * ns
    ns.sort[(ns.length / 2).floor]
  end

  def self.memorize_with(get_key, &action)
    cache = {}
    ->(*args, **kwargs) do
      key = get_key.(*args, **kwargs).to_sym
      cache[key] = action.(*args, **kwargs) unless cache[key]
      cache[key]
    end
  end

  def self.negate n
    -n
  end

  def self.xor? a, b
    (a && !b) || (!a && b)
  end
end
