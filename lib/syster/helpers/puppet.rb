module Syster
  module Helpers
    module Puppet
      def self.initialized
        unless defined? @@PUPPET
          require 'puppet'
          ::Puppet.initialize_settings
          @@PUPPET = ::Puppet
        end

        return @@PUPPET
      end
    end
  end
end
