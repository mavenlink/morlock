require 'morlock/gem_client'

class Morlock
  DEFAULT_EXPIRATION = 60

  attr_accessor :client

  def initialize(client)
    @client = Morlock::GemClient.wrap(client)
  end

  def lock(key, options = {})
    lock_obtained = @client.add(key, options[:expiration] || DEFAULT_EXPIRATION)
    yield if lock_obtained && block_given?
    options[:success].call if lock_obtained && options[:success]
    options[:failure].call if !lock_obtained && options[:failure]
    lock_obtained
  ensure
    @client.delete(key) if lock_obtained
  end
end