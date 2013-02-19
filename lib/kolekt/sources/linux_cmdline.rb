require 'kolekt/sources/base'

module Kolekt::Sources
  class LinuxCmdline < Base
    def self.identifier
      'linux_cmdline'
    end

    def self.runnable?
      File.exists? '/proc/cmdline'
    end

    def dry
      Kolekt::Helpers::BootId::dry
    end

    def collect
      [true, File.read('/proc/cmdline').strip]
    end
  end
end
