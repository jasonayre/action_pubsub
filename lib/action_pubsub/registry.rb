require 'trax_core'

module ActionPubsub
  class Registry
    @registry = ::ActionPubsub::Route.spawn('/')

    class << self
      attr_accessor :registry
    end

    def self.register(path)
      paths = ::Trax::Core::PathPermutations.new(*path.split('/'))


      paths.each do |path|
        puts path.classify
      end
      # puts paths
      paths
    end

    def self.add(path)
      segs = path.split('/')
      segs.each do |seg|
        puts seg
      end
    end

    def register_queue(exchange_name, subscriber_name)
      register_exchange(exchange_name) unless key?(exchange_name)
      exchange_hash = self[exchange_name].instance_variable_get("@data").value
      exchange_keys = exchange_hash.keys
      queue_name = [exchange_name, subscriber_name].join("/")
      self[exchange_name].add(subscriber_name) { ::ActionPubsub::Queue.spawn(queue_name) }
    end

    # def register_path(*args, root:nil)
    #   root = args.shift unless root
    #
    #   root_queue = self[root]
    # end

    def register(path)
      segs = path.split('/')
      root_path = segs.shift
      segs.repeated_permutations(root_path)
    end


    # def register_exchange(exchange_name)
    #   add(exchange_name) {
    #     ::ActionPubsub::Queue.spawn(exchange_name)
    #   }
    # end
  end
end
