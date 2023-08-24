class String
  def head
    self[0]
  end

  def tail
    self[1...length] || ""
  end

  def init
    length == 0 ? "" : self[0...(length - 1)]
  end

  def last
    self[length - 1]
  end
end