# frozen_string_literal: true

require 'lib/special'
require 'lib/trait/applicative'

module Alternative
  include Applicative

  # empty is required as class method

  def or other
    raise Special::UNIMPLEMENTED
  end
end
