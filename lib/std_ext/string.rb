class String
  def head
    first
  end

  def tail
    last(length - 1)
  end

  def init
    first(length - 1)
  end
end