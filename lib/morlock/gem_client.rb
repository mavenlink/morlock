class Morlock
  class UnknownGemClient < StandardError; end

  class GemClient
    GEM_CLIENTS = []

    def initialize(client)
      @client = client
    end

    def self.wrap(client)
      GEM_CLIENTS.each do |gem, gem_client|
        if (eval(gem) rescue false) && client.is_a?(eval(gem))
          return gem_client.new(client)
        end
      end

      raise UnknownGemClient.new("You provided Morlock a memcached client of an unknown type: #{client.class}")
    end

    def delete(key)
      @client.delete(key)
    end
  end

  class DalliGemClient < GemClient
    def add(key, expiration)
      @client.add(key, 1, expiration)
    end
  end
  GemClient::GEM_CLIENTS << ["Dalli::Client", DalliGemClient]

  class MemcacheGemClient < GemClient
    def add(key, expiration)
      @client.add(key, 1, expiration, true) !~ /NOT_STORED/
    end
  end
  GemClient::GEM_CLIENTS << ["MemCache", MemcacheGemClient]
end