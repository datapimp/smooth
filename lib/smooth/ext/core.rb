class Hash
  def to_mash
    Hashie::Mash.new(dup)
  end
end

class NilClass
  def empty?
    true
  end
end

class String
  def empty?
    length == 0
  end
end
