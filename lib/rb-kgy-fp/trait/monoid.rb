# frozen_string_literal: true

require_relative '../special'
require_relative '../trait/semi_group'

module Monoid
  include SemiGroup

  # implement require: mempty | mconcat

  def self.mempty
    mconcat []
  end

  def mappend other
    assoc(other)
  end

  def self.mconcat ls
    ls.reverse.reduce(mempty) do |acc, item|
      acc.mappend(item)
    end
  end
end
