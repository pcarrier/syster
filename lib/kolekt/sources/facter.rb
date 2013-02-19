require 'kolekt/sources/base'

module Kolekt; module Sources; class Facter < Base
  def self.runnable?
    begin
      require 'facter'
      return true
    rescue LoadError
      return false
    end
  end

  def collect
    used_puppet = false

    begin
      require 'puppet'
      Puppet.parse_config
      unless $LOAD_PATH.include?(Puppet[:libdir])
        $LOAD_PATH << Puppet[:libdir]
      end
      used_puppet = true
    rescue LoadError => detail
      $stderr.puts "Could not load Puppet: #{detail}"
    end

    require 'facter'
    ::Facter.loadfacts
    res = ::Facter.to_hash
    res['used_puppet'] = used_puppet

    [true, res]
  end
end; end; end
