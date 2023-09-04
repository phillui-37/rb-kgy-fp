# frozen_string_literal: true

require_relative '../special'
require_relative '../fun'
require_relative '../curry_fun'
require_relative '../trait/semi_group'
require_relative '../trait/monad'
require_relative '../trait/bi_functor'

class Either
  include SemiGroup, Monad, Comparable, BiFunctor

  attr_reader :value

  private

  public

  def inspect = to_s

  def initialize value
    @value = value
  end

  def left?
    raise Special::UNIMPLEMENTED
  end

  def right?
    !left?
  end

  def self.of value
    Right.new value
  end

  def either map_left, map_right
    raise Special::UNIMPLEMENTED
  end

  def <=> other
    if right?
      other.left? ? -1 : @value <=> other.value
    else
      other.right? ? 1 : @value <=> other.value
    end
  end
end

class Left < Either

  def assoc other
    other
  end

  def fmap & fn
    self
  end

  def apply(other)
    self
  end

  def bind(&fn)
    self
  end

  def left?
    true
  end

  def to_s
    "Left(#{@value})"
  end

  def either(map_left, _)
    map_left.(@value)
  end

  def bimap(map_fst, map_snd)
    Left.new map_fst.(@value)
  end
end

class Right < Either
  def assoc other
    self
  end

  def fmap & fn
    of fn.(@value)
  end

  def apply(other)
    of @value.(other)
  end

  def bind(&fn)
    fn.(@value)
  end

  def left?
    false
  end

  def to_s
    "Right(#{@value})"
  end

  def either(_, map_right)
    map_right.(@value)
  end

  def bimap(map_fst, map_snd)
    of map_snd.(@value)
  end
end