module Calabash
  # @!visibility private
  module HTTP
    require 'calabash/http/retriable_client'
    require 'calabash/http/forwarding_client'
    require 'calabash/http/request'
    require 'calabash/http/error'
  end
end
