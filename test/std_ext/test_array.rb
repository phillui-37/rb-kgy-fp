require 'lib/std_ext/array'
require 'minitest/test'

class StdExtListTest < Minitest::Test
  def setup
    @ls = [1,2,3,4,5]
  end

  def test_head
    assert_equal @ls.head, 1
  end

  def test_tail
    assert_equal @ls.tail, [2,3,4,5]
  end
end