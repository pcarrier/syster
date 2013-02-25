require 'syster/sources/base'
require 'syster/helpers/boot_id'

module Syster::Sources
  class LinuxCmdline < Base
    def self.identifier
      'linux_cmdline'
    end

    def self.runnable?
      File.exists? '/proc/cmdline'
    end

    def dry
      Syster::Helpers::BootId::dry
    end

    def collect
      [true, File.read('/proc/cmdline').strip]
    end
  end
end
