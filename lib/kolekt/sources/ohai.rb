require 'kolekt/sources/base'

module Kolekt::Sources
  class Ohai < Base
    def self.runnable?
      Kolekt::Helpers::Require.can_require? %w[ohai]
    end

    def collect
      require 'ohai'
      sys = ::Ohai::System.new
      sys.all_plugins
      return [true, sys]
    end
  end
end
