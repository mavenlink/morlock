require 'morlock/gem_client'

class Morlock
  DEFAULT_EXPIRATION = 60

  attr_accessor :client

  def initialize(client)
    @client = Morlock::GemClient.wrap(client)
  end

  def lock(key, options = {})
    lock_obtained = @client.add(key, options[:expiration] || DEFAULT_EXPIRATION)
    puts "Lock for #{key} #{lock_obtained ? "obtained" : "not obtained"}." if options[:verbose]
    yield if lock_obtained && block_given?
    options[:success].call if lock_obtained && options[:success]
    options[:failure].call if !lock_obtained && options[:failure]
    lock_obtained
  ensure
    if lock_obtained
      if @client.delete(key)
        puts "Lock removed for #{key}" if options[:verbose]
      else
        puts "Someone else removed the lock for #{key}!" if options[:verbose]
      end
    end
  end
end