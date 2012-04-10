require "morlock/version"
require 'morlock/base'

class Morlock
  class MorlockRailtie < ::Rails::Railtie
    def self.setup_for_mem_cache_store
      if Rails.cache.instance_variable_get(:@data)
        Rails.module_eval do
          class << self
            def morlock
              @@morlock ||= Morlock.new(Rails.cache.instance_variable_get(:@data))
            end
          end
        end
      else
        Rails.logger.warn "WARNING: Morlock could not load @data in #setup_for_mem_cache_store.  Perhaps we don't yet work with this version of Rails?"
      end
    end

    def self.setup_for_dalli_store
      self.setup_for_mem_cache_store
    end

    def self.setup_for_test_store
      Rails.module_eval do
        class << self
          def morlock
            @@morlock ||= Morlock.new(:test)
          end
        end
      end
    end

    def self.detect_memcache_gem
      if defined?(ActiveSupport::Cache::MemCacheStore) && Rails.cache.is_a?(ActiveSupport::Cache::MemCacheStore)
        setup_for_mem_cache_store
      elsif defined?(ActiveSupport::Cache::DalliStore) && Rails.cache.is_a?(ActiveSupport::Cache::DalliStore)
        setup_for_dalli_store
      elsif Rails.env.test?
        setup_for_test_store
      else
        Rails.logger.warn "WARNING: Morlock detected that you are not using the Rails ActiveSupport::Cache::MemCacheStore.  Rails.morlock will not be setup."
      end
    end

    config.after_initialize do
      detect_memcache_gem
    end
  end
end