require 'lib/std_ext/array'
require 'minitest/test'

class StdExtListTest < Minitest::Test
  def setup
    @ls = [1,2,3,4,5]
  end

  def test_head
    assert_equal 1, @ls.head
  end

  def test_tail
    assert_equal [2,3,4,5], @ls.tail
  end

  def test_init
    assert_equal [1,2,3,4], @ls.init
  end

  def test_xprod
    #todo
  end
end