module Kolekt; module Helpers; module Path
  def self.dirs
    @@DIRS ||= ENV['PATH'].split ':'
  end

  def self.find pattern
      dirs.find do |dir|
        begin
          Dir.entries(dir).find {|e| pattern === e}
        rescue Errno::ENOENT
        end
      end
  end
end; end; end
