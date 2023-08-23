class Array
  def head
    first
  end

  def tail
    last(length - 1)
  end

  def init
    first(length - 1)
  end

  def xprod arr2
    ret = []
    self.each do |item1|
      arr2.each do |item2|
        ret << [item1, item2]
      end
    end
    ret
  end
end
