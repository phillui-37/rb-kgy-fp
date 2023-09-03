# frozen_string_literal: true

require_relative '../trait/monad'

class State
  include Monad

  private_class_method :new

  def self.of & action
    new &action
  end

  def self.get
    of { |s| [s, s] }
  end

  def self.put state
    of { |_| [nil, state] }
  end

  private

  def initialize & action
    @action = action
  end

  public

  def fmap(&fn)
    of do |state|
      run_state(state) => [value, this_state]
      [fn.(value), this_state]
    end
  end

  def apply(other)
    of do |state|
      run_state(state) => [fn, this_state]
      other.run_state(this_state) => [value, other_state]
      [fn.(value), other_state]
    end
  end

  def bind & fn
    of do |s|
      run_state(s) => [value, this_state]
      fn.(value).run_state(this_state)
    end
  end

  def run_state state
    @action.(state)
  end

  def eval_state state
    run_state(state)[0]
  end

  def exec_state state
    run_state(state)[1]
  end
end
