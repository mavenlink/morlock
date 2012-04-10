class Morlock
  class UnknownGemClient < StandardError; end


  class GemClient
    GEM_CLIENTS = []

    def initialize(client)
      @client = client
    end

    def self.wrap(client)
      return TestGemClient.new(nil) if client == :test

      GEM_CLIENTS.each do |gem, gem_client|
        if (eval(gem) rescue false) && client.is_a?(eval(gem))
          return gem_client.new(client)
        end
      end

      raise UnknownGemClient.new("You provided Morlock with a memcached client of an unknown type: #{client.class}")
    end

    def no_server_error(e)
      STDERR.puts "WARNING: No memcached server was found; Memlock was unable to create a lock. (#{e.message})"
      true
    end
  end


  class DalliGemClient < GemClient
    def add(key, expiration)
      @client.add(key, 1, expiration)
    rescue => e
      no_server_error e
    end

    def delete(key)
      @client.delete(key)
    rescue => e
      true
    end
  end
  GemClient::GEM_CLIENTS << ["Dalli::Client", DalliGemClient]

  class MemcacheGemClient < GemClient
    def add(key, expiration)
      @client.add(key, 1, expiration, true) !~ /NOT_STORED/
    rescue MemCache::MemCacheError => e
      no_server_error e
    end

    def delete(key)
      @client.delete(key)
    rescue MemCache::MemCacheError => e
      true
    end
  end
  GemClient::GEM_CLIENTS << ["MemCache", MemcacheGemClient]


  class TestGemClient < GemClient
    def add(key, expiration)
      true
    end

    def delete(key)
      true
    end
  end
end