require 'kolekt/sources/base'

module Kolekt; module Sources; class LinuxCmdline < Base
  def self.identifier
    'linux_cmdline'
  end

  def self.runnable?
    File.exists? '/proc/cmdline'
  end

  def dry
    Kolekt::Helpers::BootId::dry
  end

  def collect
    begin
      return [true, File.read('/proc/cmdline').strip]
    rescue Exception => e
      return [false, "exception (#{e})"]
    end
  end
end; end; end
