require 'kolekt/sources/base'
require 'kolekt/helpers/boot_id'

module Kolekt::Sources
  class LinuxCpuInfo < Base
    def self.identifier
      'cpuinfo'
    end

    def self.runnable?
      File.exists? '/proc/cpuinfo'
    end

    def dry
      Kolekt::Helpers::BootId::dry
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
