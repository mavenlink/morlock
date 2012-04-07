# Morlock

Morlock turns your memcached server into a distributed, conflict-eating machine.  Rails integration is dug in.

## Usage

### Creating a new Morlock instance

#### Ruby

	require 'memcache-client'
	require 'morlock'

	mem_cache_client = MemCache.new("memcached.you.com")
    morlock = Morlock.new(mem_cache_client)

If you prefer Dalli, use that instead:

	require 'dalli'
	dc = Dalli::Client.new('localhost:11211')
  morlock = Morlock.new(dc)

#### Rails

If you're already using MemCacheStore in your Rails app, using Morlock is trivial.  Morlock will automatically use the memcached server that is backing Rails.cache.

With Bundler:

	gem 'morlock', :require => 'morlock/rails'

Or in any script after Rails has loaded:

	require 'morlock/rails'

At this point, `Rails.morlock` should be defined and available.  Use it instead of `morlock` in the examples below.

### Distributed Locking

Possible usages:

	handle_failed_lock unless morlock.lock(key) do
		# We have the lock
	end
	
	morlock.lock(key) { # We have the lock } || raise "Unable to lock!"

	morlock.lock(key, :failure => failure_proc) do
		# We have the lock
	end

	morlock.lock(key, :failure => failure_proc, :success => success_proc)
