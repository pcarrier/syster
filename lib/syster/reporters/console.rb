require 'syster/reporters/base'
require 'pp'

module Syster::Reporters
  class Console < Base
    def report name, payload
      puts "=== #{name} ==="
      pp payload
    end
  end
end
