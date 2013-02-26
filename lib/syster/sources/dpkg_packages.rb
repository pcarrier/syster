require 'syster/sources/base'
require 'syster/helpers/path'

module Syster::Sources
  class DpkgPackages < Base
    def self.identifier
      'dpkg_packages'
    end

    def self.runnable?
      Syster::Helpers::Path::find 'dpkg'
    end

    def dry
      begin
        s = File.stat '/var/lib/dpkg/status'
        return [true, [s.mtime.to_i, s.size]]
      rescue
        return [false, 'can\'t stat /var/lib/dpkg/status']
      end
    end

    def collect
      packages = {}
      %x[dpkg-query -Wf '${Package}\t${Architecture}\t${Status}\t${Version}\n'].lines.each do |line|
        pkg, arch, status, version = line.strip.split "\t"
        packages[pkg] ||= {}
        packages[pkg][arch] = [status, version]
      end

      return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0

      [true, packages]
    end
  end
end
