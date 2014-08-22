Mutations.cache_constants = false

class Hash
  def to_mash
    Hashie::Mash.new(dup)
  end
end
