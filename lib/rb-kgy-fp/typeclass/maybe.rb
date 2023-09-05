# frozen_string_literal: true

require_relative '../special'
require_relative '../fun'
require_relative '../curry_fun'
require_relative '../trait/monad'
require_relative '../trait/alternative'
require 'singleton'

class Maybe
  include Monad, Alternative, Comparable

  def inspect = to_s

  def just?
    raise Special::UNIMPLEMENTED
  end

  def nothing?
    !just?
  end

  def self.of value
    Just.new value
  end

  def <=> other
    if just?
      other.nothing? ? -1 : @value <=> other.value
    else
      other.nothing? ? 0 : 1
    end
  end

  def self.empty
    Nothing.new
  end

  def consume(other)
    replace other
  end

  def get
    throw RuntimeError
  end
end

class Just < Maybe
  attr_reader :value

  def to_s = "Just(#{@value.to_s})"

  def initialize value
    @value = value
  end

  def just?
    true
  end

  def fmap(&fn)
    of fn.(@value)
  end

  def apply(other)
    other.fmap(&@value)
  end

  def lift_a2(other, &fn)
    if other.just?
      of fn.(@value, other.value)
    else
      Nothing.new
    end
  end

  def replace(other)
    other
  end

  def or(other)
    self
  end

  def bind(&fn)
    fn.(@value)
  end

  def get
    @value
  end
end

class Nothing < Maybe
  include Singleton

  def to_s = 'Nothing'

  def self.of _ = nil
    instance
  end

  def just?
    false
  end

  def fmap(&fn)
    self
  end

  def apply(other)
    self
  end

  def lift_a2(other, &fn)
    self
  end

  def replace(other)
    self
  end

  def or other
    other
  end

  def bind(&fn)
    self
  end
end