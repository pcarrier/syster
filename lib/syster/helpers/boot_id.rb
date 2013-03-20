module Syster
  module Helpers
    module BootId
      def self.boot_id
        if RUBY_PLATFORM.end_with? 'linux'
          @@BOOTID ||= File.read('/proc/sys/kernel/random/boot_id').strip
        else
          return nil
        end
      end

      def self.dry
        bid = boot_id
        if bid.nil?
          return [false, 'can\'t find a boot id']
        else
          return [true, bid]
        end
      end
    end
  end
end
