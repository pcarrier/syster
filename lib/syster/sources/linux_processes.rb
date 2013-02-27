require 'syster/sources/base'
require 'scanf'

module Syster::Sources
  class LinuxProcesses < Base
    STAT_FORMAT = '%d %s %c %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d'
    STAT_FIELDS = [:pid, :comm, :state, :ppid, :pgrp, :session, :tty_nr, :tpgid, :flags, :minflt,
                   :cminflt, :majflt, :cmajflt, :utime, :stime, :cutime, :cstime, :priority, :nice, :unused,
                   :itrealvalue, :starttime, :vsize, :rss, :rlim, :startcode, :endcode, :startstack, :kstkesp, :kstkeip,
                   :signal, :blocked, :sigignore, :sigcatch, :wchan, :nswap, :cnswap, :exit_signal, :processor, :rt_priority,
                   :policy, :delayacct_blkio_ticks, :guest_time, :cguest_time]

    def self.identifier
      'linux_processes'
    end

    def self.runnable?
      # BSDs don't have /proc/$PID
      File.exists? '/proc/1/cmdline'
    end

    def collect
      res = {}

      Dir.entries('/proc').each do |e|
        # skip non-process entries
        next unless e =~ /^[0-9]+$/

        begin
          rstat = File.read "/proc/#{e}/stat"
          stat = Hash[STAT_FIELDS.zip(rstat.scanf(STAT_FORMAT)).delete_if{|k,v| v.nil?}]

          cmd = File.read("/proc/#{e}/cmdline").split("\0").collect do |i|
            i.gsub ' ', '\ '
          end.join ' '

          comm = stat[:comm] ? stat[:comm][1..-2] : 'unknown'
          stat[:comm] = comm
          stat[:cmd] = cmd

          res[comm] ||= []
          res[comm] << stat
        rescue Errno::ENOENT
          # ignore processes disappearing under our feet
        end
      end

      return [true, res]
    end
  end
end
