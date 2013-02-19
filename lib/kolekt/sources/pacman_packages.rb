require 'kolekt/sources/base'

module Kolekt; module Sources; class PacmanPackages < Base
  def self.identifier
    'pacman_packages'
  end

  def self.runnable?
    Kolekt::Helpers::Path::find 'pacman'
  end

  def dry
    begin
      return [true, File.mtime('/var/lib/pacman/local').to_i]
    rescue
      return [false, 'can\'t stat /var/lib/pacman/local']
    end
  end

  def collect
    packages = Hash[
      %x[pacman -Q'].lines.collect do |line|
      line.strip.split ' '
    end]
    
    return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0
    
    [true, packages]
  end
end; end; end
