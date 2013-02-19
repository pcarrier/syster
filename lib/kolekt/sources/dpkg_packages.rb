require 'kolekt/sources/base'

module Kolekt; module Sources; class DpkgPackages < Base
  def self.identifier
    'dpkg_packages'
  end

  def self.runnable?
    Kolekt::Helpers::Path::find 'dpkg'
  end

  def dry
    begin
      s = File.stat('/var/lib/dpkg/status')
      return [true, [s.mtime.to_i, s.size]]
    rescue
      return [false, 'can\'t stat /var/lib/dpkg/status']
    end
  end

  def collect
    packages = Hash[
      %x[dpkg-query -Wf '${Package}\t${Architecture}\t${Status}\t${Version}\n'].lines.collect do |line|
      fields = line.strip.split "\t"
      next [fields[0..1], fields[2..-1]]
    end]
    
    return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0
    
    [true, packages]
  end
end; end; end
