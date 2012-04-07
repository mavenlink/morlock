class Morlock
  class MorlockRailtie < ::Rails::Railtie
    config.after_initialize do
      if defined?(ActiveSupport::Cache::MemCacheStore) && Rails.cache.is_a?(ActiveSupport::Cache::MemCacheStore) && Rails.cache.instance_variable_get(:@data)
        Rails.module_eval do
          class << self
            def morlock
              @@morlock ||= Morlock.new(Rails.cache.instance_variable_get(:@data))
            end
          end
        end
      else
        Rails.logger.warn "WARNING: Morlock detected that you are not using the Rails ActiveSupport::Cache::MemCacheStore.  Rails.morlock will not be setup."
      end
    end
  end
end