require 'syster/sources/base'
require 'syster/helpers/puppet'

module Syster::Sources
  class Facter < Base
    def self.runnable?
      Syster::Helpers::Require.can_require? %w[facter]
    end

    def collect
      used_puppet = false

      begin
        Syster::Helpers::Puppet.initialized
        unless $LOAD_PATH.include?(Puppet[:libdir])
          $LOAD_PATH << Puppet[:libdir]
        end
        used_puppet = true
      rescue LoadError
        # ignored, we'll just remember
      end

      require 'facter'
      ::Facter.loadfacts
      res = ::Facter.to_hash
      res['used_puppet'] = used_puppet

      [true, res]
    end
  end
end
