require 'syster/sources/base'
require 'syster/helpers/boot_id'

module Syster::Sources
  class LinuxVersion < Base
    def self.identifier
      'linux_version'
    end

    DIR = '/proc/sys/kernel'
    FILES = %w[ostype osrelease version]

    def self.runnable?
      File.exists? File.join(DIR, 'ostype')
    end

    def dry
      Syster::Helpers::BootId::dry
    end

    def collect
      [true, Hash[FILES.collect do |fname|
        [fname, File.read(File.join(DIR, fname)).strip]
      end]]
    end
  end
end
