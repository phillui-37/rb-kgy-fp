class Array
  def head
    self[0]
  end

  def tail
    self[1, length]
  end
end
