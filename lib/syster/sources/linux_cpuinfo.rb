require 'syster/sources/base'
require 'syster/helpers/boot_id'

module Syster::Sources
  class LinuxCpuInfo < Base
    def self.identifier
      'cpuinfo'
    end

    def self.runnable?
      File.exists? '/proc/cpuinfo'
    end

    def dry
      Syster::Helpers::BootId::dry
    end

    def collect
      [true, File.read('/proc/cpuinfo').
        split("\n\n").collect do |cpu|
          Hash[
            cpu.split("\n").collect do |line|
              line.split(/\t+: /)
            end
          ]
        end]
    end
  end
end
