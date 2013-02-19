require 'kolekt/reporters/base'
require 'pp'

module Kolekt::Reporters
  class Console < Base
    def report name, payload
      puts "=== #{name} ==="
      pp payload
    end
  end
end
