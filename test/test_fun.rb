require 'lib/fun'
require 'minitest/test'

class TestFun < Minitest::Test
  def test_eq?
    assert Fun::eq?(1, 1)
    assert Fun::eq?("a", "a")
    assert Fun::eq?(:e, :e)
    assert Fun::eq?([1], [1])
    assert Fun::eq?(%w[1 2 3 4], ["1", "2", "3", "4"])
    assert Fun::eq?(1.1, 1.1)
    assert Fun::eq?(1.0/0, 1.0/0)
    assert Fun::eq?(-1.0/0, -1.0/0)
  end

  def test_ne?
    assert Fun::ne?(1, 2)
    assert Fun::ne?(1.1, 1.2)
    assert Fun::ne?(:e, :f)
    assert Fun::ne?([1], [])
    assert Fun::ne?(%w[], ["1"])
    assert Fun::ne?(1, "1")
    assert Fun::ne?(0.0/0, 0.0/0)
    assert Fun::ne?(1, "1")
  end

  def test_gt?

  end

  def test_ge?

  end

  def test_lt?

  end

  def test_le?

  end

  def test_id
    assert_equal Fun::id(1), 1
    assert Fun::id(->(){}) != ->(){}
  end

  def test_const
    assert_equal Fun::const(1, nil), 1
    assert_nil Fun::const(nil, 1), ""
  end

  def test_pipe
    assert_equal Fun::pipe(
      nil,
      ->(_) {Fun::const(1, _)},
      ->(n) {n.to_s},
    ), "1"
  end

  def test_compose
    assert_equal Fun::compose(
      "wow",
      ->(s) {s + "123"},
      ->(n) {n.to_s},
    ), "wow123"
  end

  def test_not?

  end

  def test_nil_or

  end

  def test_nil_or_else
    assert_equal Fun::nil_or_else(nil) {1}, 1
    assert_equal Fun::nil_or_else(2) {1}, 2
  end
end