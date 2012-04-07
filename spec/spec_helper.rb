require 'rubygems'
require 'bundler/setup'
require 'morlock'
require 'rr'

RSpec.configure do |config|
  config.mock_with :rr
end
