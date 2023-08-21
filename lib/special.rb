require 'singleton'

class PlaceHolder
  include Singleton
end

__ = PlaceHolder.instance

# todo normal arg => :req, optional arg => :opt
# *arg => :rest, c: => :keyreq, d: '...' => :key
# **kargs => :keyrest