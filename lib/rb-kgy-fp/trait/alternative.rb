# frozen_string_literal: true

require_relative '../special'
require_relative '../trait/applicative'

module Alternative
  include Applicative

  # empty is required as class method

  def or other
    raise Special::UNIMPLEMENTED
  end
end
