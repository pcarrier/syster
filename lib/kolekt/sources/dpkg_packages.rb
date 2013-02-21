require 'kolekt/sources/base'
require 'kolekt/helpers/path'

module Kolekt::Sources
  class DpkgPackages < Base
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
      packages = Hash.new({})
      %x[dpkg-query -Wf '${Package}\t${Architecture}\t${Status}\t${Version}\n'].lines.each do |line|
        pkg, arch, status, version = line.strip.split "\t"
        packages[pkg][arch] = [status, version]
      end

      return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0

      [true, packages]
    end
  end
end
