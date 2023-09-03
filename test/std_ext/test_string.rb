require 'lib/rb-kgy-fp/std_ext/string'
require 'minitest/test'

class StdExtStringTest < Minitest::Test
  def setup
    @s = "abcd1234"
    @empty = ""
  end

  def test_head
    assert_equal "a", @s.head
    assert_nil @empty.head
  end

  def test_tail
    assert_equal "bcd1234", @s.tail
    assert_equal "", @empty.tail
  end

  def test_init
    assert_equal "abcd123", @s.init
    assert_equal "", @empty.init
  end

  def test_last
    assert_equal "4", @s.last
    assert_nil @empty.last
  end
end