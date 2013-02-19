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

  def dry
    Kolekt::Helpers::BootId::dry
  end

  def collect
    [true, Hash[FILES.collect { |fname|
      [fname, File.read(File.join(DIR, fname)).strip]
    }]]
  end
end; end; end
