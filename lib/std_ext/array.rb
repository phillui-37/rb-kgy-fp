# frozen_string_literal: true

class Array
  def head
    first
  end

  def tail
    length <= 1 ? [] : last(length - 1)
  end

  def init
    length == 0 ? [] : first(length - 1)
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
