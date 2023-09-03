# frozen_string_literal: true

require_relative '../trait/monad'
require_relative '../fun'
require_relative '../curry_fun'

class Reader
  include Monad

  private_class_method :new

  def self.of &reader
    new &reader
  end

  def self.ask
    of &Fun.method(:id)
  end

  def self.asks &fn
    of do |env|
      fn.(ask.run_reader(env))
    end
  end

  private

  def initialize &reader
    @reader = reader
  end

  public

  def fmap(&fn)
    of do |env|
      fn.(run_reader(env))
    end
  end

  def apply(other)
    of do |env|
      run_reader(env).run_reader(env)
    end
  end

  def bind(&fn)
    of do |env|
      fst = run_reader(env)
      fn.(fst).run_reader(env)
    end
  end

  def run_reader env
    @reader.(env)
  end

  def map_reader &fn
    of CurryFun.pipe(@reader, fn)
  end

  def with_reader &fn
    of CurryFun.pipe(fn, @reader)
  end
end
