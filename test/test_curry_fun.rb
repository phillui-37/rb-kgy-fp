require 'lib/curry_fun'
require 'minitest/test'

class CurryFunTest < Minitest::Test
  def test_eq?
    assert CurryFun::eq?(1, 1)
    assert CurryFun::eq?(1).(1)
  end
end