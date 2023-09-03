# frozen_string_literal: true

require_relative '../special'
require_relative '../fun'
require_relative '../curry_fun'
require_relative '../trait/monad'
require_relative '../trait/alternative'

class Maybe
  include Monad, Alternative, Comparable

  private

  public

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
end

class Just < Maybe
  attr_reader :value
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

end

class Nothing < Maybe
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