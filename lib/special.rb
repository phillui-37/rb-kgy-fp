require 'singleton'

module Special
  class PlaceHolder
    include Singleton
  end

  PH = PlaceHolder.instance

  class Optional
    include Singleton
  end

  OPT = Optional.instance
end