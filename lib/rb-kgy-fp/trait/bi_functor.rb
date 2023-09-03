# frozen_string_literal: true

require_relative '../special'
require_relative '../fun'

module BiFunctor
  # implement require: bimap | (first, second)
  def bimap map_fst, map_snd
    second(&map_snd).first(&map_fst)
  end

  def first &fn
    bimap fn, Fun.method(:id)
  end

  def second &fn
    bimap Fun.method(:id), fn
  end
end
