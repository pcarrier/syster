require 'kolekt/sources/base'

module Kolekt; module Sources; class LinuxVersion < Base
  def self.identifier
    'linux_version'
  end

  DIR = '/proc/sys/kernel'
  FILES = %w[ostype osrelease version]

  def self.runnable?
    File.exists? File.join(DIR, 'ostype')
  end

  def collect
    begin
      res = Hash[FILES.collect do |fname|
        [fname, File.read(File.join(DIR, fname)).strip]
      end]
      
      return [true, res]
    rescue Exception => e
      return [false, "exception (#{e})"]
    end
  end
end; end; end
