require 'kolekt/sources/base'

module Kolekt::Sources
  class LinuxModules < Base
    def self.identifier
      'linux_modules'
    end

    def self.runnable?
      File.exists? '/proc/modules'
    end

    def collect
      [true, File.read('/proc/modules').lines.collect do |l|
        l.split(' ', 2).first
      end.sort]
    end
  end
end
