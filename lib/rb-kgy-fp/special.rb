# frozen_string_literal: true

require 'singleton'

module Special
  private
  class UnimplementedError < RuntimeError
    def to_s
      "Unimplemented Error: Please check the code for implementation"
    end
  end

  public
  class PlaceHolder
    include Singleton
  end

  PH = PlaceHolder.instance

  class Optional
    include Singleton
  end

  OPT = Optional.instance

  UNIMPLEMENTED = UnimplementedError.new
end