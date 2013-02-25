require 'syster/reporters/base'
require 'pp'

module Syster::Reporters
  class JSON < Base
    def self.runnable?
      Syster::Helpers::Require.can_require? %w[json]
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
