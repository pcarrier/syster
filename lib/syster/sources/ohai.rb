require 'syster/sources/base'

module Syster::Sources
  class Ohai < Base
    def self.runnable?
      Syster::Helpers::Require.can_require? %w[ohai]
    end

    def collect
      require 'ohai'
      sys = ::Ohai::System.new
      sys.all_plugins
      return [true, sys.data]
    end
  end
end
