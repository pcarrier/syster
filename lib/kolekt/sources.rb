require 'kolekt/sources/augeas'
require 'kolekt/sources/dpkg_packages'
require 'kolekt/sources/facter'
require 'kolekt/sources/linux_cmdline'
require 'kolekt/sources/linux_modules'
require 'kolekt/sources/linux_mounts'
require 'kolekt/sources/linux_version'
require 'kolekt/sources/lspci'
require 'kolekt/sources/ohai'
require 'kolekt/sources/pacman_packages'

module Kolekt; module Sources
  def self.available
    @@AVAILABLE ||= constants.collect { |c| const_get(c) }.
      select { |c| c.instance_of? Class and c.identifier != 'base' }
  end
end; end
