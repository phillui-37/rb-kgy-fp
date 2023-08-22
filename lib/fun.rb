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

  # todo normal arg => :req, optional arg => :opt
  # *arg => :rest, c: => :keyreq, d: '...' => :key
  # **kargs => :keyrest
  # Not supporting yield
  def self.curry(&fn)
    require "special"
    using Special
    module ParamFlag
      REQ = 1 << 0
      OPT = 1 << 1
      REST = 1 << 2
      KREQ = 1 << 3
      KOPT = 1 << 4
      KREST = 1 << 5
      BLOCK = 1 << 6
    end
    params = []
    remain_param_count = 0

    # check params
    fn.parameters.each do |detail|
      detail => [type, name]
      case type
      when :req
        params << { name: name, value: PH, type: ParamFlag::REQ }
        remain_param_count += 1
      when :opt
        params << { name: name, value: OPT, type: ParamFlag::OPT }
      when :rest
        params << { name: name, type: ParamFlag::REST }
      when :keyreq
        params << { name: name, value: PH, type: ParamFlag::KREQ }
        remain_param_count += 1
      when :key
        params << { name: name, value: OPT, type: ParamFlag::KOPT }
      when :keyrest
        params << { name: name, type: ParamFlag::KREST }
      when :block
        params << { name: name, value: PH, type: ParamFlag::BLOCK }
        remain_param_count += 1
      end
    end

    ->(*args, **kwargs, &proc) do
      using ParamFlag
      arg_idx = 0
      _kwargs = {**kwargs}

      (0..params.length).each { |i|
        param = params[i]
        filled = param.value != PH && param.value != OPT

        if (param.type & (REQ | OPT)) != 0 && !filled
          param.value = args[arg_idx]
          arg_idx += 1
          remain_param_count -= 1 if param.type == REQ
        end

        if (param.type & (KREQ | KOPT) != 0) && !filled && _kwargs[param.name] != nil
          param.value = _kwargs.delete(param.name)
          remain_param_count -= 1 if param.type == KREQ
        end

        if param.type == BLOCK && !filled && proc
          param.value = proc
          remain_param_count -= 1
        end
      }

      if args.length - 1 > arg_idx && params.any? { |p| p.type == REST }
        params.find { |p| p.type == REST }.value = args[arg_idx, -1]
      end

      if _kwargs.length > 0 && params.any? {|p| p.type == KREST}
        params.find { |p| p.type == KREST }.value = _kwargs
      end

      if remain_param_count == 0
        _params = []
        _kparams = {}
        _proc = nil
        params.each do |param|
          case param.type
          when REQ, OPT
            _params << param.value
          when KREQ, KOPT
            _kparams[param.name] = param.value
          when REST
            _params.concat(*param.value)
          when KREST
            _kparams.merge(param.value)
          when PROC
            _proc = param.value
          end
        end
        if _proc
          fn.(*_params, **_kparams, &_proc)
        else
          fn.(*_params, **_kparams)
        end
      else
        # TODO
      end
    end

  end
end
