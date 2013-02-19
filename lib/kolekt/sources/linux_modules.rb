require 'kolekt/sources/base'

module Kolekt; module Sources; class LinuxModules < Base
  def self.identifier
    'linux_modules'
  end

  def self.runnable?
    File.exists? '/proc/modules'
  end

  def collect
    begin
      list = File.read('/proc/modules').lines.collect do |l|
        l.split(' ', 2).first
      end.sort
      
      return [true, list]
    rescue Exception => e
      return [false, "exception (#{e})"]
    end
  end
end; end; end
