%w[
  augeas
  dpkg_packages
  facter
  linux_cmdline
  linux_modules
  linux_mounts
].each do |m|
    require "kolekt/sources/#{m}"
end

module Kolekt; module Sources
  def self.available
    @@AVAILABLE ||= constants.collect { |c| const_get(c) }.
      select { |c| c.instance_of?(Class) && c.identifier != 'base' }
  end
end; end
