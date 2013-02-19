require 'kolekt/sources/base'

module Kolekt; module Sources; class LinuxMounts < Kolekt::Sources::Base
  def self.identifier
    'linux_mounts'
  end

  def self.runnable?
    File.exists? '/proc/mounts'
  end

  def collect
    begin
      entries = File.read('/proc/mounts').lines.collect do |l|
        spec, point, type, optstr, dump, passno = l.strip.split " "
        options = Hash[optstr.split(',').collect { |e|
          next e.split('=', 2) if e.include? '='
          next e, true
        }]

          next :spec => spec,
               :point => point,
               :type => type,
               :options => options,
               :dump => dump,
               :passno => passno
        end

      [true, entries]
    rescue Exception => e
      return [false, "exception (#{e})"]
    end
  end
end; end; end
