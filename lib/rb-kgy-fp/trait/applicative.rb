# frozen_string_literal: true

require_relative "../special"
require_relative '../fun'
require_relative '../curry_fun'
require_relative '../trait/functor'

module Applicative
  include Functor

  # implement require: apply | lift_a2
  # of is required as class method

  # <*>
  def apply other
    lift_a2(other, &Fun.method(:id))
  end

  def lift_a2 other, &fn
    apply(other.map(&fn))
  end

  # *>
  def replace other
    update(Fun.method(:id)).apply(other)
  end

  # <*
  def const other
    lift_a2(other, &CurryFun.method(:const))
  end
end
