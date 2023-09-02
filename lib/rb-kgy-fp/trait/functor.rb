# frozen_string_literal: true

require 'lib/special'
require 'lib/curry_fun'

module Functor
  def fmap &fn
    raise Special::UNIMPLEMENTED
  end

  # <$
  def update value
    map(&CurryFun::const(value))
  end
end
