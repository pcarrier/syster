require 'kolekt/reporters/base'
require 'pp'

module Kolekt::Reporters
  class JSON < Base
    def self.runnable?
      Kolekt::Helpers::Require.can_require? %w[json]
    end

    def initialize opts={}
      require 'json'
      @payload = {}
    end

    def report name, payload
      @payload[name] = payload
    end

    def finish
      ::JSON::dump @payload, $stdout
    end
  end
end
