# frozen_string_literal: true

require 'lib/trait/monad'

class Writer
  include Monad

  private_class_method :new

  def self.of value, stack
    new value, stack
  end

  def self.tell stack = []
    of nil, stack
  end

  private

  def initialize value = nil, stack = []
    @value = value
    @stack = stack
    @stack.freeze
    @stack.each { |item| item.freeze }
  end

  public

  def fmap(&fn)
    of fn.(@value), @stack
  end

  def apply(other)
    of @value.(other.map_writer), [*@stack, *other.exec_writer]
  end

  def bind(&fn)
    fn.(@value).run_writer => [new_value, new_stack]
    of new_value, [*@stack, *new_stack]
  end

  def run_writer
    [@value, @stack]
  end

  def exec_writer
    @stack
  end

  def map_writer
    @value
  end
end
