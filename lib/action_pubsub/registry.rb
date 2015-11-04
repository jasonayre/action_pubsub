module ActionPubsub
  class Registry < ::Concurrent::LazyRegister
    def []=(key, val)
      register(key) { val }
    end

    def keys
      @data.value.keys
    end
  end
end
