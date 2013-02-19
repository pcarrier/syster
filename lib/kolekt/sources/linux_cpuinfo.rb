require 'kolekt/sources/base'

module Kolekt; module Sources; class LinuxCpuInfo < Base
  def self.identifier
    'linux_cpuinfo'
  end

  def self.runnable?
    File.exists? '/proc/cpuinfo'
  end

  def dry
    Kolekt::Helpers::BootId::dry
  end

  def collect
    begin
      return [true, File.read('/proc/cpuinfo').
        split("\n\n").collect do |cpu|
          Hash[
            cpu.split("\n").collect do |line|
              line.split(/\t+: /)
            end
          ]
        end]
    rescue Exception => e
      return [false, "exception (#{e})"]
    end
  end
end; end; end
