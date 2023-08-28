require 'lib/curry_fun'
require 'minitest/test'

class CurryFunTest < Minitest::Test
  private

  def comparable_helper(method_sym, * ls)
    fn = CurryFun.method(method_sym)
    ls.each do |entry|
      entry => [fst, snd]
      assert fn.(fst, snd)
      assert fn.(fst).(snd)
    end
  end

  public

  def test_eq?
    comparable_helper(
      :eq?,
      [1, 1],
      ["a", "a"],
      [:e, :e],
      [[], []],
      [[1], [1]],
      [%w[1 2 3 4], ["1", "2", "3", "4"]],
      [1.1, 1.1],
      [1.0 / 0, 1.0 / 0],
      [-1.0 / 0, -1.0 / 0],
      [{ test: 1 }, { test: 1 }],
      [{}, {}],
    )
  end

  def test_ne?
    comparable_helper(
      :ne?,
      [1, 0],
      ["a", "b"],
      [:e, :f],
      [[], [1]],
      [[1], %w[1]],
      [%w[1], ["1", "2", "3", "4"]],
      [1.1, 1.2],
      [-1.0 / 0, 1.0 / 0],
      [0.0 / 0, 0.0 / 0],
      [{ test: 1 }, { test: 2 }],
      [{ test: 1 }, {}],
    )
  end

  def test_gt?
    comparable_helper(
      :gt?,
      [2, 1],
      ["b", "a"],
      [1.2, 1.1],
      [1.0 / 0.0, -1.0 / 0.0],
      [[1], []],
      [[2], [1]],
      [[2, 1], [2]],
      [[2, 3], [2, 1]],
      [{ test: 1 }, {}],
    )
  end

  def test_ge?
    comparable_helper(
      :ge?,
      [2, 1],
      [2, 2],
      ["b", "a"],
      ["b", "b"],
      [1.2, 1.1],
      [1.1, 1.1],
      [1.0 / 0.0, -1.0 / 0.0],
      [[], []],
      [[1], []],
      [[1], [1]],
      [[2], [1]],
      [[2, 1], [2]],
      [[2, 3], [2, 1]],
      [{ test: 1 }, {}],
      [{}, {}],
    )
  end

  def test_lt?
    comparable_helper(
      :lt?,
      [1, 2],
      ["a", "b"],
      [1.1, 1.2],
      [-1.0 / 0.0, 1.0 / 0.0],
      [[], [1]],
      [[2], [3]],
      [[2, 1], [2, 1, 3]],
      [[2, 3], [2, 4]],
      [{ test: 1 }, { test: 1, test2: 4 }],
    )
  end

  def test_le?
    comparable_helper(
      :le?,
      [1, 2],
      [2, 2],
      ["a", "b"],
      ["a", "a"],
      [1.0, 1.1],
      [1.1, 1.1],
      [-1.0 / 0.0, 1.0 / 0.0],
      [[], []],
      [[], [1]],
      [[1], [1]],
      [[1], [2]],
      [[2], [2, 1]],
      [[2, 3], [2, 4]],
      [{}, { test: 1 }],
      [{}, {}],
    )
  end

  def test_const
    assert_equal 1, CurryFun::const(1, nil)
    assert_nil CurryFun::const(nil, 1)

    assert_nil CurryFun::const(nil).(1)
    assert_equal 1, CurryFun::const(1).(nil)
  end

  def test_pipe
    fn1 = CurryFun::pipe(
      CurryFun::const(1),
      ->(n) { n.to_s },
    )
    assert_equal "1", fn1.(nil)
    assert_equal "1", fn1.('wow')
  end

  def test_compose
    fn1 = CurryFun::compose(
      ->(s) { s + "123" },
      ->(n) { n.to_s },
    )
    assert_equal "wow123", fn1.("wow")
    assert_equal "11123", fn1.(11)
  end

  def test_not?
    ne = CurryFun::not? { |a, b| a == b }
    assert ne.(1, 2)

    eq = CurryFun::not? { |a, b| a != b }
    assert eq.(1, 1)

    contains = CurryFun::not? { |target, obj| obj.values.all? { |v| v != target } }
    assert contains.(1, { a: 1, b: 2 })
  end

  def test_nil_or
    assert_equal 1, CurryFun::nil_or(nil, 1)
    assert_nil CurryFun::nil_or(nil, nil)
    assert_equal 1, CurryFun::nil_or(1, nil)

    assert_equal 1, CurryFun::nil_or(nil).(1)
    assert_nil CurryFun::nil_or(nil).(nil)
    assert_equal 1, CurryFun::nil_or(1).(nil)
  end

  def test_nil_or_else
    assert_equal 1, CurryFun::nil_or_else(value: nil) { 1 }
    assert_equal 2, CurryFun::nil_or_else(value: 2) { 1 }

    assert_equal 1, CurryFun::nil_or_else(get_fallback: -> { 1 }, value: nil)
    assert_equal 2, CurryFun::nil_or_else(get_fallback: -> { 1 }, value: 2)

    assert_equal 1, CurryFun::nil_or_else(get_fallback: -> { 1 }).(nil)
    assert_equal 2, CurryFun::nil_or_else(get_fallback: -> { 1 }).(2)

    assert_equal 1, CurryFun::nil_or_else { 1 }.(nil)
    assert_equal 2, CurryFun::nil_or_else { 1 }.(2)

    assert_raises(ArgumentError) do
      CurryFun::nil_or_else(get_fallback: -> { 1 }) { 1 }
    end
    assert_raises(ArgumentError) do
      CurryFun::nil_or_else()
    end
  end

  def test_not_nil_or
    assert_nil CurryFun::not_nil_or(nil, 1)
    assert_nil CurryFun::not_nil_or(nil, nil)
    assert_nil CurryFun::not_nil_or(1, nil)

    assert_nil CurryFun::not_nil_or(nil).(1)
    assert_nil CurryFun::not_nil_or(nil).(nil)
    assert_nil CurryFun::not_nil_or(1).(nil)
  end

  def test_not_nil_or_else
    assert_nil CurryFun::not_nil_or_else(value: nil) { 1 }
    assert_equal 1, CurryFun::not_nil_or_else(value: 2) { 1 }

    assert_nil CurryFun::not_nil_or_else(get_fallback: -> { 1 }, value: nil)
    assert_equal 1, CurryFun::not_nil_or_else(get_fallback: -> { 1 }, value: 2)

    assert_nil CurryFun::not_nil_or_else(get_fallback: -> { 1 }).(nil)
    assert_equal 1, CurryFun::not_nil_or_else(get_fallback: -> { 1 }).(2)

    assert_nil CurryFun::not_nil_or_else { 1 }.(nil)
    assert_equal 1, CurryFun::not_nil_or_else { 1 }.(2)

    assert_raises(ArgumentError) do
      CurryFun::not_nil_or_else(get_fallback: -> { 1 }) { 1 }
    end
    assert_raises(ArgumentError) do
      CurryFun::not_nil_or_else()
    end
  end

  def test_not_nil_map
    assert_nil CurryFun::not_nil_map(value: nil) { |obj| obj.to_s }
    assert_nil CurryFun::not_nil_map(mapper: :to_s, value: nil)
    assert_equal 2, CurryFun::not_nil_map(value: 1) { |n| n + 1 }

    assert_nil CurryFun::not_nil_map(mapper: ->(obj) { obj.to_s }, value: nil)
    assert_nil CurryFun::not_nil_map(mapper: :to_s, value: nil)
    assert_equal 2, CurryFun::not_nil_map(mapper: ->(n) { n + 1 }, value: 1)

    assert_nil CurryFun::not_nil_map { |obj| obj.to_s }.(nil)
    assert_equal 2, CurryFun::not_nil_map { |n| n + 1 }.(1)

    assert_nil CurryFun::not_nil_map(mapper: ->(obj) { obj.to_s }).(nil)
    assert_nil CurryFun::not_nil_map(mapper: :to_s).(nil)
    assert_equal 2, CurryFun::not_nil_map(mapper: ->(n) { n + 1 }).(1)

    assert_raises(ArgumentError) { CurryFun::not_nil_map() }
    assert_raises(ArgumentError) { CurryFun::not_nil_map(mapper: -> {}) {} }
    assert_raises(ArgumentError) { CurryFun::not_nil_map(mapper: :to_s) {} }
    assert_raises(NameError) { CurryFun::not_nil_map(mapper: :hi, value: 1) }
  end

  def test_add
    assert_equal 3, CurryFun::add(1, 2)
    cf = CurryFun::add(1)
    assert_equal 3, cf.(2)
    assert_equal 5, cf.(4)
  end

  def test_minus
    assert_equal 2, CurryFun::minus(3, 1)
    cf = CurryFun::minus(5)
    assert_equal 3, cf.(2)
    assert_equal 1, cf.(4)
  end

  def test_mul
    assert_equal 3, CurryFun::mul(3, 1)
    cf = CurryFun::mul(5)
    assert_equal 10, cf.(2)
    assert_equal 20, cf.(4)
  end

  def test_div
    assert_equal 1, CurryFun::div(3, 2)
    assert_equal 1.5, CurryFun::div(3, 2.0)
    cf = CurryFun::div(5.0)
    assert_equal 2.5, cf.(2)
    assert_equal 1.25, cf.(4)
  end

  def test_mod
    assert_equal 2, CurryFun::mod(5, 3)
    assert_equal 2, CurryFun::mod(5).(3)
    cf = CurryFun::mod(10)
    assert_equal 3, cf.(7)
    assert_equal 1, cf.(3)
  end

  def test_flip
    assert_equal 2, CurryFun::flip(3, 5) { |a, b| a - b }
    assert_equal [1], CurryFun::flip([2, 3], [1, 2, 3]) { |a, b| a - b }

    assert_equal 2, CurryFun::flip(3).(5) { |a, b| a - b }
    assert_equal 2, CurryFun::flip(3) { |a, b| a - b }.(5)
    assert_equal 2, CurryFun::flip(3).(&->(a, b) { a - b }).(5)
    assert_equal 2, CurryFun::flip(3).(5).(&->(a, b) { a - b })
  end

  def test_all?
    fn = CurryFun.method(:all?)
    assert fn.(args: [2, 4, 6]) { |n| n.even? }
    assert fn.(fn: :even?, args: [2, 4, 6])
    assert fn.(fn: :even?).(2, 4, 6)
    assert fn.() { |n| n.even? }.(2, 4, 6)

    assert_raises(ArgumentError) { fn.() }
    assert_raises(ArgumentError) { fn.(fn: :hi) {} }
    assert_raises(NameError) { fn.(fn: :hi, args: [1]) }
  end

  def test_any?
    fn = CurryFun.method(:any?)
    assert fn.(args: [1, 3, 4]) { |n| n.even? }
    assert fn.(fn: :even?, args: [1, 3, 4])
    assert fn.(fn: :even?).(1, 3, 4)
    assert fn.() { |n| n.even? }.(1, 3, 4)

    assert_raises(ArgumentError) { fn.() }
    assert_raises(ArgumentError) { fn.(fn: :hi) {} }
    assert_raises(NameError) { fn.(fn: :hi, args: [1]) }
  end

  def test_and?
    fn = CurryFun.method(:and?)
    assert fn.(true, true)
    assert !fn.(true, false)
    assert fn.(1, 2)

    assert fn.(true).(true)
    assert !fn.(true).(false)
    assert fn.(1).(2)
  end

  def test_or?
    fn = CurryFun.method(:or?)
    assert fn.(true, false)
    assert !fn.(false, false)
    assert fn.(1, 0)

    assert fn.(true).(false)
    assert !fn.(false).(false)
    assert fn.(1).(0)
  end

  def test_xor?
    fn = CurryFun.method(:xor?)
    assert fn.(true, false)
    assert !fn.(false, false)
    assert !fn.(true, true)

    assert fn.(true).(false)
    assert !fn.(false).(false)
    assert !fn.(true).(true)
  end

  def test_clamp
    fn = CurryFun.method(:clamp)
    assert_equal 3, fn.(1, 3, 10)
    assert_equal 1, fn.(1, 3, -10)

    assert_equal 3, fn.(1).(3).(10)
    assert_equal 1, fn.(1).(3).(-10)

    assert_equal 3, fn.(1, 3).(10)
    assert_equal 1, fn.(1, 3).(-10)
  end

  def test_cond
    cond_mapper = [
      [->(_, **kwargs) { kwargs[:tag] == "test" }, ->(n, **_) { n + 1 }],
      [->(n) { n & 1 }, ->(n) { n / 2.0 }]
    ]
    assert_nil CurryFun::cond(cond_mapper).()
    assert_equal 2, CurryFun::cond(cond_mapper).(1, tag: "test")
    assert_equal 1.5, CurryFun::cond(cond_mapper).(3)
  end

  def test_desc
    h1 = { test: 4, a: 5, c: 3 }
    sorted_h1_keys = CurryFun::desc { |k, _| k }.(h1).keys
    assert_equal sorted_h1_keys, %w[test c a].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    sorted_h1_keys2 = CurryFun::desc { |_, v| v }.(h1).keys
    assert_equal sorted_h1_keys2, %w[a test c].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    arr1 = Array(1..4)
    assert_equal arr1.reverse, CurryFun::desc { |x| x }.(arr1)
    assert_equal Array(1..4), arr1
  end

  def test_asc
    h1 = { test: 4, a: 5, c: 3 }
    sorted_h1_keys = CurryFun::asc { |k, _| k }.(h1).keys
    assert_equal sorted_h1_keys, %w[a c test].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    sorted_h1_keys2 = CurryFun::asc { |_, v| v }.(h1).keys
    assert_equal sorted_h1_keys2, %w[c test a].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    arr1 = Array(4..1)
    assert_equal arr1.reverse, CurryFun::asc { |x| x }.(arr1)
    assert_equal Array(4..1), arr1
  end

  def test_diff
    assert_equal [1, 4], CurryFun::diff([1, 2, 3, 4], [2, 3])
    assert_equal [2, 4, 5, 6], CurryFun::diff([1, 3], [2, 4, 5, 6])
    assert_equal({ b: 2, c: 3 }, CurryFun::diff({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({ a: 2 }, CurryFun::diff({ a: 1 }, { a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4 }, CurryFun::diff({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))

    assert_equal [1, 4], CurryFun::diff([1, 2, 3, 4]).([2, 3])
    assert_equal [2, 4, 5, 6], CurryFun::diff([1, 3]).([2, 4, 5, 6])
    assert_equal({ b: 2, c: 3 }, CurryFun::diff({ a: 1, b: 2, c: 3 }).({ a: 1 }))
    assert_equal({ a: 2 }, CurryFun::diff({ a: 1 }).({ a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4 }, CurryFun::diff({ a: 1, b: 2, c: 3, d: 4 }).({ e: 5 }))
  end

  def test_intersect
    assert_equal [2, 3], CurryFun::intersect([1, 2, 3, 4], [2, 3])
    assert_equal [], CurryFun::intersect([1, 3], [2, 4, 5, 6])
    assert_equal({ a: 1 }, CurryFun::intersect({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({}, CurryFun::intersect({ a: 1 }, { a: 2 }))
    assert_equal({}, CurryFun::intersect({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))

    assert_equal [2, 3], CurryFun::intersect([1, 2, 3, 4]).([2, 3])
    assert_equal [], CurryFun::intersect([1, 3]).([2, 4, 5, 6])
    assert_equal({ a: 1 }, CurryFun::intersect({ a: 1, b: 2, c: 3 }).({ a: 1 }))
    assert_equal({}, CurryFun::intersect({ a: 1 }).({ a: 2 }))
    assert_equal({}, CurryFun::intersect({ a: 1, b: 2, c: 3, d: 4 }).({ e: 5 }))
  end

  def test_non_intersect
    assert_equal [1, 4], CurryFun::non_intersect([1, 2, 3, 4], [2, 3])
    assert_equal [1, 3, 2, 4, 5, 6], CurryFun::non_intersect([1, 3], [2, 4, 5, 6])
    assert_equal({ b: 2, c: 3 }, CurryFun::non_intersect({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({ a: 2 }, CurryFun::non_intersect({ a: 1 }, { a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4, e: 5 }, CurryFun::non_intersect({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))

    assert_equal [1, 4], CurryFun::non_intersect([1, 2, 3, 4]).([2, 3])
    assert_equal [1, 3, 2, 4, 5, 6], CurryFun::non_intersect([1, 3]).([2, 4, 5, 6])
    assert_equal({ b: 2, c: 3 }, CurryFun::non_intersect({ a: 1, b: 2, c: 3 }).({ a: 1 }))
    assert_equal({ a: 2 }, CurryFun::non_intersect({ a: 1 }).({ a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4, e: 5 }, CurryFun::non_intersect({ a: 1, b: 2, c: 3, d: 4 }).({ e: 5 }))
  end

  def test_union
    assert_equal [1, 2, 3, 4], CurryFun::union([1, 2, 3, 4], [2, 3])
    assert_equal [1, 3, 2, 4, 5, 6], CurryFun::union([1, 3], [2, 4, 5, 6])
    assert_equal({ a: 1, b: 2, c: 3 }, CurryFun::union({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({ a: 2 }, CurryFun::union({ a: 1 }, { a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4, e: 5 }, CurryFun::union({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))

    assert_equal [1, 2, 3, 4], CurryFun::union([1, 2, 3, 4]).([2, 3])
    assert_equal [1, 3, 2, 4, 5, 6], CurryFun::union([1, 3]).([2, 4, 5, 6])
    assert_equal({ a: 1, b: 2, c: 3 }, CurryFun::union({ a: 1, b: 2, c: 3 }).({ a: 1 }))
    assert_equal({ a: 2 }, CurryFun::union({ a: 1 }).({ a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4, e: 5 }, CurryFun::union({ a: 1, b: 2, c: 3, d: 4 }).({ e: 5 }))
  end
end