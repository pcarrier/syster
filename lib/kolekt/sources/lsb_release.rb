require 'kolekt/sources/base'

module Kolekt; module Sources; class LsbRelease < Base
  def self.identifier
    'lsb_release'
  end

  def self.runnable?
     Kolekt::Helpers::Path.find 'lsb_release'
  end

  def dry
    Kolekt::Helpers::BootId::dry
  end

  def collect
    res = Hash[
      %w[distributor description release codename].zip(
        %x[lsb_release -as].lines.collect{|l|l.strip})
    ]

    return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0
    [true, res]
  end
end; end; end
