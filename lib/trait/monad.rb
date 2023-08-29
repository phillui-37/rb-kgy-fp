# frozen_string_literal: true

require 'lib/special'
require 'lib/curry_fun'
require 'lib/trait/applicative'

module Monad
  include Applicative

  # >>=
  def bind & fn
    raise Special::UNIMPLEMENTED
  end

  # >>
  def consume other
    bind { |_| other }
  end

end
