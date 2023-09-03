require 'lib/rb-kgy-fp/std_ext/array'
require 'minitest/test'

class StdExtListTest < Minitest::Test
  def setup
    @ls = [1,2,3,4,5]
    @empty = []
  end

  def test_head
    assert_equal 1, @ls.head
    assert_nil @empty.head
  end

  def test_tail
    assert_equal [2,3,4,5], @ls.tail
    assert_equal [], @empty.tail
  end

  def test_init
    assert_equal [1,2,3,4], @ls.init
    assert_equal [], @empty.init
  end

  def test_xprod
    assert_equal [[1,3], [1,4], [2,3], [2,4]], @ls.take(2).xprod([3,4])
    assert_equal [], @empty.xprod(@ls)
  end
end