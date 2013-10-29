require 'syster/sources/base'
require 'scanf'

module Syster::Sources
  class LinuxProcesses < Base
    # From Linux man-pages 3.47
    # Had to murder %l+[ud] into %f to help JSON & mongodb
    STAT_SPECS = [
      [:pid, '%d'],
      [:comm, '%s'],
      [:state, '%c'],
      [:ppid, '%d'],
      [:pgrp, '%d'],
      [:session, '%d'],
      [:tty_nr, '%d'],
      [:tpgid, '%d'],
      [:flags, '%u'],
      [:minflt, '%f'],
      [:cminflt, '%f'],
      [:majflt, '%f'],
      [:cmajflt, '%f'],
      [:utime, '%f'],
      [:stime, '%f'],
      [:cutime, '%f'],
      [:cstime, '%f'],
      [:priority, '%f'],
      [:nice, '%f'],
      [:num_threads, '%f'],
      [:itrealvalue, '%f'],
      [:starttime, '%f'],
      [:vsize, '%f'],
      [:rss, '%f'],
      [:rsslim, '%f'],
      [:startcode, '%f'],
      [:endcode, '%f'],
      [:startstack, '%f'],
      [:kstkesp, '%f'],
      [:kstkeip, '%f'],
      [:signal, '%f'],
      [:blocked, '%f'],
      [:sigignore, '%f'],
      [:sigcatch, '%f'],
      [:wchan, '%f'],
      [:nswap, '%f'],
      [:cnswap, '%f'],
      [:exit_signal, '%d'],
      [:processor, '%d'],
      [:rt_priority, '%u'],
      [:policy, '%u'],
      [:delayacct_blkio_ticks, '%f'],
      [:guest_time, '%f'],
      [:cguest_time, '%f']
    ]

    STAT_FORMAT = STAT_SPECS.collect {|n,f| f}.join ' '
    STAT_FIELDS = STAT_SPECS.collect {|n,f| n}

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
          stat[:cmd] = cmd unless cmd.empty?
          stat[:exe] = File.readlink("/proc/#{e}/exe")

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
