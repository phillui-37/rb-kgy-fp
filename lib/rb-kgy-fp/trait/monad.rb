# frozen_string_literal: true

require_relative '../special'
require_relative '../curry_fun'
require_relative '../trait/applicative'

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
