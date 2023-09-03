# frozen_string_literal: true

require_relative '../special'
require_relative '../curry_fun'

module Functor
  def fmap &fn
    raise Special::UNIMPLEMENTED
  end

  # <$
  def update value
    map(&CurryFun::const(value))
  end
end
