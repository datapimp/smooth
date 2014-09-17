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

  def self.random_token length=12
    rand(36**36).to_s(36).slice(0, length)
  end
end
