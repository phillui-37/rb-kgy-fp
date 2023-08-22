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

  def self.all?(items, *fns)
    fns.reduce(true) { |result, fn| result && fn.(items) }
  end

  def self.any?(items, *fns)
    fns.reduce(false) { |result, fn| result || fn.(items) }
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
    cond_mappers.each { |fns|
      fns => { cond:, mapper: }
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

    core = ->(this, fn, c_params=[], c_remain_param_count=0) do
      ->(*args, **kwargs, &proc) do
        cp_c_params = Marshal.load(Marshal.dump(c_params))
        cp_c_remain_param_count = c_remain_param_count
        arg_idx = 0
        _kwargs = {**kwargs}

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

        if _kwargs.length > 0 && cp_c_params.any? {|p| p[:type] == krest}
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
end
