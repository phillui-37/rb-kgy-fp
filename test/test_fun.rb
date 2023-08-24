require 'lib/fun'
require 'minitest/test'

class TestFun < Minitest::Test
  def test_eq?
    assert Fun::eq?(1, 1)
    assert Fun::eq?("a", "a")
    assert Fun::eq?(:e, :e)
    assert Fun::eq?([], [])
    assert Fun::eq?([1], [1])
    assert Fun::eq?(%w[1 2 3 4], ["1", "2", "3", "4"])
    assert Fun::eq?(1.1, 1.1)
    assert Fun::eq?(1.0 / 0, 1.0 / 0)
    assert Fun::eq?(-1.0 / 0, -1.0 / 0)
    assert Fun::eq?({ test: 1 }, { test: 1 })
    assert Fun::eq?({}, {})
  end

  def test_ne?
    assert Fun::ne?(1, 2)
    assert Fun::ne?(1.1, 1.2)
    assert Fun::ne?(:e, :f)
    assert Fun::ne?([1], [])
    assert Fun::ne?(%w[], ["1"])
    assert Fun::ne?(1, "1")
    assert Fun::ne?(0.0 / 0, 0.0 / 0)
    assert Fun::ne?(1, "1")
    assert Fun::ne?({ test: 1 }, { test: 2 })
    assert Fun::ne?({ test: 1 }, {})
  end

  def test_gt?
    assert Fun::gt?(2, 1)
    assert Fun::gt?("b", "a")
    assert Fun::gt?(1.2, 1.1)
    assert Fun::gt?(1.0 / 0.0, -1.0 / 0.0)
    assert Fun::gt?([1], [])
    assert Fun::gt?([2], [1])
    assert Fun::gt?([2, 1], [2])
    assert Fun::gt?([2, 3], [2, 1])
    assert Fun::gt?({ test: 1 }, {})
  end

  def test_ge?
    assert Fun::ge?(2, 1)
    assert Fun::ge?(2, 2)
    assert Fun::ge?("b", "a")
    assert Fun::ge?("b", "b")
    assert Fun::ge?(1.2, 1.1)
    assert Fun::ge?(1.1, 1.1)
    assert Fun::ge?(1.0 / 0.0, -1.0 / 0.0)
    assert Fun::ge?([], [])
    assert Fun::ge?([1], [])
    assert Fun::ge?([1], [1])
    assert Fun::ge?([2], [1])
    assert Fun::ge?([2, 1], [2])
    assert Fun::ge?([2, 3], [2, 1])
    assert Fun::ge?({ test: 1 }, {})
    assert Fun::ge?({}, {})
  end

  def test_lt?
    assert Fun::lt?(1, 2)
    assert Fun::lt?("a", "b")
    assert Fun::lt?(1.1, 1.2)
    assert Fun::lt?(-1.0 / 0.0, 1.0 / 0.0)
    assert Fun::lt?([], [1])
    assert Fun::lt?([2], [3])
    assert Fun::lt?([2, 1], [2, 1, 3])
    assert Fun::lt?([2, 3], [2, 4])
    assert Fun::lt?({ test: 1 }, { test: 1, test2: 4 })
  end

  def test_le?
    assert Fun::le?(1, 2)
    assert Fun::le?(2, 2)
    assert Fun::le?("a", "b")
    assert Fun::le?("a", "a")
    assert Fun::le?(1.0, 1.1)
    assert Fun::le?(1.1, 1.1)
    assert Fun::le?(-1.0 / 0.0, 1.0 / 0.0)
    assert Fun::le?([], [])
    assert Fun::le?([], [1])
    assert Fun::le?([1], [1])
    assert Fun::le?([1], [2])
    assert Fun::le?([2], [2, 1])
    assert Fun::le?([2, 3], [2, 4])
    assert Fun::le?({}, { test: 1 })
    assert Fun::le?({}, {})
  end

  def test_id
    assert_equal 1, Fun::id(1)
    assert Fun::id(->() {}) != ->() {} # check by ref, lambda should not be equal

    def f; end

    assert_equal :f, Fun::id(:f)

    f2 = ->() {}
    assert_equal f2, Fun::id(f2)
  end

  def test_const
    assert_equal 1, Fun::const(1, nil)
    assert_nil Fun::const(nil, 1)
  end

  def test_pipe
    assert_equal "1", Fun::pipe(
      nil,
      ->(_) { Fun::const(1, _) },
      ->(n) { n.to_s },
    )
  end

  def test_compose
    assert_equal "wow123", Fun::compose(
      "wow",
      ->(s) { s + "123" },
      ->(n) { n.to_s },
    )
  end

  def test_not?
    assert Fun::not?(->(*xs) { xs.all? { |x| x > 1 } }, 0, -1, -2)
  end

  def test_nil_or
    assert_equal 1, Fun::nil_or(nil, 1)
    assert_nil Fun::nil_or(nil, nil)
    assert_equal 1, Fun::nil_or(1, nil)
  end

  def test_nil_or_else
    assert_equal 1, Fun::nil_or_else(nil) { 1 }
    assert_equal 2, Fun::nil_or_else(2) { 1 }
  end

  def test_not_nil_or
    assert_nil Fun::not_nil_or(nil, 1)
    assert_equal 1, Fun::not_nil_or(2, 1)
  end

  def test_not_nil_or_else
    assert_nil Fun::not_nil_or_else(nil) { 1 }
    assert_equal 1, Fun::not_nil_or_else(2) { 1 }
  end

  def test_not_nil_map
    assert_nil Fun::not_nil_map(nil) { |_| }
    assert_equal 2, Fun::not_nil_map(1) { |n| n + 1 }
  end

  def test_add
    assert_equal 3, Fun::add(1, 2)
    assert_equal "ab", Fun::add("a", "b")
    assert_equal Array(1..4), Fun::add([1, 2], [3, 4])
    assert_equal 4.6, Fun::add(1.2, 3.4)
  end

  def test_minus
    assert_equal(-1, Fun::minus(1, 2))
    assert_equal [2], Fun::minus([1, 2], [1])
    assert_equal(-2.2, Fun::minus(1.2, 3.4))
  end

  def test_mul
    assert_equal "ababababab", Fun::mul("ab", 5)
    assert_equal 20, Fun::mul(5, 4)
    assert_equal 2.2, Fun::mul(1.1, 2)
    assert_equal %w[a b a b], Fun::mul(%w[a b], 2)
  end

  def test_div
    assert_equal 1, Fun::div(5, 4)
    assert_equal 1.25, Fun::div(5.0, 4)
  end

  def test_mod
    assert_equal 1, Fun::mod(5, 2)
    assert_equal 5.0 % 1.5, Fun::mod(5.0, 1.5)
  end

  def test_flip
    assert_equal "ba", Fun::flip("a", "b", &Fun.method(:add))
  end

  def test_all?
    assert Fun::all?(2, ->(n) { n > 1 }, ->(n) { n.even? })
    assert Fun::all?(->(n) { n.even? }, 0, 2, 4)
  end

  def test_any?
    assert Fun::any?(2, ->(n) { n > 1 }, ->(n) { n < 1 })
    assert Fun::any?(->(n) { n.even? }, 2, 4, 6)
  end

  def test_clamp
    assert_equal 10, Fun::clamp(1, 10, 100)
    assert_equal 1, Fun::clamp(1, 10, -1)
    assert_equal 2, Fun::clamp(1, 10, 2)
  end

  def test_cond
    cond_mapper = [
      [->(_, **kwargs) { kwargs[:tag] == "test" }, ->(n, **_) { n + 1 }],
      [->(n) { n & 1 }, ->(n) { n / 2.0 }]
    ]
    assert_nil Fun::cond(cond_mapper)
    assert_equal 2, Fun::cond(cond_mapper, 1, tag: "test")
    assert_equal 1.5, Fun::cond(cond_mapper, 3)
  end

  def test_curry
    # all possible argument type
    raw_fn = ->(a, b = 2, *c, d:, e: 3, **f, &g) {
      _c = c[0] || 3
      g.(a + b + _c - d - e - f.values.reduce(:+))
    }
    expected = (1 + 6 + 3 - 4 - 3 - 6) / 10.0
    f = Fun::curry(&raw_fn)
    result = f.(1, 6, 3, d: 4, f: 6) do |n|
      n / 10.0
    end
    assert_equal expected, result

    f2 = f.(6, 1, k: 6)
    assert_equal expected, f2.(d: 4) { |n| n / 10.0 }

    # no argument
    f3 = Fun::curry(&->() { "Hello World" })
    assert_equal "Hello World", f3.()

    # no proc
    f4 = Fun::curry(&->(a, b = 2, *c, d:, e: 5, **f) {
      _c = c[0] || 3
      a + b + _c + d + e + f.values.reduce(:+)
    })
    assert_equal 1 + 100 + 3 + 4 + 5 + 6 + 7, f4.(1, 100, 3, 10, d: 4, k: 6, j: 7)
  end

  def test_dec
    assert_equal 0, Fun::dec(1)
    assert_equal 1.1, Fun::dec(2.1)
  end

  def test_inc
    assert_equal 2, Fun::inc(1)
    assert_equal 3.1, Fun::inc(2.1)
  end

  def test_desc
    h1 = { test: 4, a: 5, c: 3 }
    sorted_h1_keys = Fun::desc(h1) { |k, _| k }.keys
    assert_equal sorted_h1_keys, %w[test c a].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    sorted_h1_keys2 = Fun::desc(h1) { |_, v| v }.keys
    assert_equal sorted_h1_keys2, %w[a test c].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    arr1 = Array(1..4)
    assert_equal arr1.reverse, Fun::desc(arr1, &Fun.method(:id))
    assert_equal Array(1..4), arr1
  end

  def test_asc
    h1 = { test: 4, a: 5, c: 3 }
    sorted_h1_keys = Fun::asc(h1) { |k, _| k }.keys
    assert_equal sorted_h1_keys, %w[a c test].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    sorted_h1_keys2 = Fun::asc(h1) { |_, v| v }.keys
    assert_equal sorted_h1_keys2, %w[c test a].map { |s| s.to_sym }
    assert_equal h1.keys, %w[test a c].map { |s| s.to_sym } # ensure method is pure

    arr1 = Array(4..1)
    assert_equal arr1.reverse, Fun::asc(arr1, &Fun.method(:id))
    assert_equal Array(4..1), arr1
  end

  def test_to_sym
    assert_equal [:a, :b, :c], %w[a b c].map(&Fun.method(:to_sym))
  end

  def test_diff
    assert_equal [1, 4], Fun::diff([1, 2, 3, 4], [2, 3])
    assert_equal [2, 4, 5, 6], Fun::diff([1, 3], [2, 4, 5, 6])
    assert_equal({ b: 2, c: 3 }, Fun::diff({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({ a: 2 }, Fun::diff({ a: 1 }, { a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4 }, Fun::diff({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))
  end

  def test_intersect
    assert_equal [2, 3], Fun::intersect([1, 2, 3, 4], [2, 3])
    assert_equal [], Fun::intersect([1, 3], [2, 4, 5, 6])
    assert_equal({ a: 1 }, Fun::intersect({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({}, Fun::intersect({ a: 1 }, { a: 2 }))
    assert_equal({}, Fun::intersect({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))
  end

  def test_non_intersect
    assert_equal [1, 4], Fun::non_intersect([1, 2, 3, 4], [2, 3])
    assert_equal [1, 3, 2, 4, 5, 6], Fun::non_intersect([1, 3], [2, 4, 5, 6])
    assert_equal({ b: 2, c: 3 }, Fun::non_intersect({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({ a: 2 }, Fun::non_intersect({ a: 1 }, { a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4, e: 5 }, Fun::non_intersect({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))
  end

  def test_union
    assert_equal [1, 2, 3, 4], Fun::union([1, 2, 3, 4], [2, 3])
    assert_equal [1, 3, 2, 4, 5, 6], Fun::union([1, 3], [2, 4, 5, 6])
    assert_equal({ a: 1, b: 2, c: 3 }, Fun::union({ a: 1, b: 2, c: 3 }, { a: 1 }))
    assert_equal({ a: 2 }, Fun::union({ a: 1 }, { a: 2 }))
    assert_equal({ a: 1, b: 2, c: 3, d: 4, e: 5 }, Fun::union({ a: 1, b: 2, c: 3, d: 4 }, { e: 5 }))
  end

  def test_empty
    assert_equal({}, Fun::empty({ a: 1 }))
    assert_equal [], Fun::empty(%w[1 2 3])
    assert_equal '', Fun::empty('abcde')
    assert_nil Fun::empty(1)
    assert_nil Fun::empty(1.1)
    assert_nil Fun::empty(:test)
  end

  def test_mean
    assert_equal 2, Fun::mean(1, 2, 3)
    assert_equal 2, Fun::mean(2, 4, 0)
    assert_equal 1.1, Fun::mean(1.1, 2.2, 0)
  end

  def test_median
    assert_equal 2, Fun::median(1, 2, 3)
    assert_equal 2, Fun::median(2, 1000000000, 0)
    assert_equal 1.1, Fun::median(1.1, 2.2, -100000)
  end

  def test_memorize_with
    obj = { a: { b: 2 } }
    fn = Fun::memorize_with(->(_) { 'test' }) { |d| d[:a][:b] }
    assert_equal(2, fn.(obj))
    obj[:a][:b] = 3
    assert_equal(2, fn.(obj))

  end

  def test_negate
    assert_equal(-1, Fun::negate(1))
    assert_equal 1.1, Fun::negate(-1.1)
  end
end