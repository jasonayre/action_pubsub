module ActionPubsub
  class Registry < ::Concurrent::LazyRegister
    def all
      keys.map do |k|
        self[k]
      end
    end

    def []=(key, val)
      register(key) { val }
    end

    def keys
      @data.value.keys
    end
  end
end
