require 'kolekt/sources/base'
require 'shellwords'

module Kolekt::Sources
  class LinuxProcesses < Base
    def self.identifier
      'linux_processes'
    end

    def self.runnable?
      # BSDs don't have /proc/$PID
      File.exists? '/proc/1/cmdline'
    end

    def collect
      stats = Hash.new 0

      Dir.entries('/proc').each do |e|
        # skip non-process entries
        next unless e =~ /^[0-9]+$/

        begin
          cmd = File.read("/proc/#{e}/cmdline").split("\0").shelljoin
          stats[cmd] += 1
        rescue Errno::ENOENT
          # ignore processes disappearing under our feet
        end
      end

      return [true, stats]  
    end
  end
end
